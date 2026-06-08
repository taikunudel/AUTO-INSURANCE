#!/usr/bin/env Rscript
# Sealed multi-dataset eval API.
#
# - Datasets are declared in YAMLs under datasets/. Drop a new YAML, restart.
# - Each dataset has a SINGLE GLOBAL test set, carved out once. Test rows are
#   never served with labels in any train/eval partition. This blocks the
#   cross-trial feature-join attack: an agent cannot recover a test row's `y`
#   by finding the same row in another trial's train/eval CSV.
# - For each trial k, the non-test portion is re-split into (train_k, eval_k).
#   Different trials reshuffle independently.
# - Row IDs are opaque random tokens (`r_<hex>`); test IDs are stable across
#   the lifetime of the container, train/eval IDs are unique per (trial, partition).
# - GET endpoints are open. POST /score is admin-only (Bearer token).

suppressPackageStartupMessages({
  library(plumber); library(jsonlite); library(yaml); library(cplm)
})

DATASETS_DIR <- Sys.getenv("EVAL_DATASETS_DIR", "datasets")
SECRET_DIR   <- Sys.getenv("EVAL_SECRET_DIR",   "secrets")
LOG_PATH     <- Sys.getenv("EVAL_LOG_PATH",     "logs/submissions.jsonl")
ADMIN_TOKEN  <- Sys.getenv("EVAL_ADMIN_TOKEN",  "")
PORT         <- as.integer(Sys.getenv("PORT", "8000"))
HOST         <- Sys.getenv("HOST", "0.0.0.0")
ID_BYTES     <- 8L

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L) b else a

# ---- Process-private secrets (persisted under SECRET_DIR) -----------------
load_or_init_secrets <- function() {
  path <- file.path(SECRET_DIR, "secrets.rds")
  if (file.exists(path)) return(readRDS(path))
  set.seed(NULL)
  s <- list(master_seed = sample.int(.Machine$integer.max, 1),
            id_seed     = sample.int(.Machine$integer.max, 1))
  dir.create(SECRET_DIR, recursive = TRUE, showWarnings = FALSE)
  saveRDS(s, path); Sys.chmod(path, "0400")
  s
}
SECRETS <- load_or_init_secrets()

# ---- Pluggable metrics ----------------------------------------------------
metric_gini <- function(y, yhat) {
  df <- data.frame(y = as.numeric(y), prediction = as.numeric(yhat), baseline = 1)
  g  <- cplm::gini(loss = "y", score = "prediction", base = "baseline", data = df)
  list(value = as.numeric(g@gini[1, "prediction"]) / 100,
       se    = tryCatch(as.numeric(g@sd[1, "prediction"]) / 100,
                        error = function(e) NA_real_))
}
metric_rmse <- function(y, yhat)
  list(value = sqrt(mean((as.numeric(y) - as.numeric(yhat))^2)), se = NA_real_)
metric_mae  <- function(y, yhat)
  list(value = mean(abs(as.numeric(y) - as.numeric(yhat))),     se = NA_real_)
METRICS <- list(gini = metric_gini, rmse = metric_rmse, mae = metric_mae)

# ---- Source loaders -------------------------------------------------------
load_source <- function(src) {
  if (src$type == "r_package") {
    e <- new.env()
    do.call(library, list(src$package, character.only = TRUE, quietly = TRUE))
    do.call(data, list(src$dataset, package = src$package, envir = e))
    return(get(src$dataset, envir = e))
  }
  if (src$type == "csv")     return(read.csv(src$path, stringsAsFactors = TRUE))
  if (src$type == "parquet") {
    if (!requireNamespace("arrow", quietly = TRUE))
      stop("arrow package required for parquet sources")
    return(as.data.frame(arrow::read_parquet(src$path)))
  }
  stop(sprintf("unknown source type: %s", src$type))
}

# ---- Helpers --------------------------------------------------------------
to_csv <- function(df) {
  tmp <- tempfile(); on.exit(unlink(tmp))
  write.csv(df, tmp, row.names = FALSE)
  paste(readLines(tmp), collapse = "\n")
}

# Generate n opaque IDs from a process-private RNG seeded at startup.
# Saves/restores the global RNG so split sampling stays deterministic.
.id_state <- NULL
opaque_ids <- function(n) {
  saved <- if (exists(".Random.seed", envir = .GlobalEnv))
    .GlobalEnv$.Random.seed else NULL
  if (is.null(.id_state)) {
    set.seed(SECRETS$id_seed); .id_state <<- .GlobalEnv$.Random.seed
  } else {
    .GlobalEnv$.Random.seed <- .id_state
  }
  ids <- character(n)
  for (i in seq_len(n))
    ids[i] <- paste0("r_", paste(sprintf("%02x",
                       sample.int(256, ID_BYTES, TRUE) - 1L), collapse = ""))
  .id_state <<- .GlobalEnv$.Random.seed
  if (!is.null(saved)) .GlobalEnv$.Random.seed <- saved
  else if (exists(".Random.seed", envir = .GlobalEnv))
    rm(".Random.seed", envir = .GlobalEnv)
  ids
}

# ---- Build splits for one dataset -----------------------------------------
build_dataset <- function(cfg) {
  raw <- load_source(cfg$source)
  # Optional `prepare` block: an R expression that may join sister tables,
  # subsample, derive new columns, etc. The expression sees `raw` and assigns
  # back to it. Useful for multi-table sources like freMTPL2 (freq + sev).
  if (!is.null(cfg$prepare)) {
    env <- new.env(parent = globalenv()); env$raw <- raw
    eval(parse(text = cfg$prepare), envir = env)
    raw <- env$raw
  }
  if (!is.null(cfg$filter))
    raw <- raw[with(raw, eval(parse(text = cfg$filter))), , drop = FALSE]

  num <- cfg$predictors$numeric %||% character(0)
  fac <- cfg$predictors$factor  %||% character(0)
  resp_alias <- cfg$response_alias %||% "y"
  cols <- c(cfg$response, num, fac)
  da <- raw[, cols, drop = FALSE]
  names(da)[1] <- resp_alias
  da[[resp_alias]] <- as.numeric(da[[resp_alias]])
  for (v in fac) da[[v]] <- droplevels(as.factor(da[[v]]))

  n        <- nrow(da)
  ratios   <- cfg$splits$ratios
  n_trials <- cfg$splits$n_trials
  if (any(c("train","eval","test") %!in% names(ratios)))
    stop("ratios must contain train, eval, test")
  if (abs(sum(unlist(ratios[c("train","eval","test")])) - 1) > 1e-6)
    stop("ratios must sum to 1")

  # ---- Carve out a SINGLE GLOBAL TEST set (seed 0); never labeled in any trial
  set.seed(SECRETS$master_seed)
  perm0  <- sample.int(n)
  n_test <- floor(n * ratios$test)
  test_i <- sort(perm0[seq_len(n_test)])
  non_test_i <- setdiff(seq_len(n), test_i)

  test_ids <- opaque_ids(length(test_i))
  test_csv <- to_csv(cbind(da[test_i, names(da) != resp_alias],
                           row_id = test_ids))
  test_y   <- setNames(da[[resp_alias]][test_i], test_ids)

  # ---- Per-trial train/eval split over the non-test portion only ----------
  prop_train_in_remaining <- ratios$train / (ratios$train + ratios$eval)
  splits <- lapply(seq_len(n_trials), function(k) {
    set.seed(SECRETS$master_seed + k)
    perm_k <- sample(non_test_i)
    n_rem  <- length(perm_k)
    n_tr_k <- floor(n_rem * prop_train_in_remaining)
    tr_i   <- perm_k[seq_len(n_tr_k)]
    ev_i   <- perm_k[(n_tr_k + 1L):n_rem]
    list(
      train_csv = to_csv(cbind(da[tr_i, ], row_id = opaque_ids(length(tr_i)))),
      eval_csv  = to_csv(cbind(da[ev_i, ], row_id = opaque_ids(length(ev_i)))),
      n         = c(train = length(tr_i), eval = length(ev_i))
    )
  })
  names(splits) <- as.character(seq_len(n_trials))

  list(
    cfg      = cfg,
    splits   = splits,
    test_csv = test_csv,
    test_y   = test_y,
    info     = list(
      name               = cfg$name,
      description        = cfg$description %||% "",
      n_trials           = n_trials,
      ratios             = ratios,
      total_rows         = n,
      test_rows          = length(test_i),
      train_rows         = splits[[1]]$n[["train"]],
      eval_rows          = splits[[1]]$n[["eval"]],
      response_var       = resp_alias,
      numeric_predictors = num,
      factor_predictors  = fac,
      metric             = cfg$metric,
      design             = "single global test (sealed); per-trial train/eval re-split"
    )
  )
}

`%!in%` <- function(x, y) !(x %in% y)

# ---- Load all dataset YAMLs at startup ------------------------------------
yaml_files <- list.files(DATASETS_DIR, pattern = "\\.ya?ml$", full.names = TRUE)
# Optional filter — `EVAL_DATASETS_FILTER=auto_insurance,fremtpl2` loads only those.
filter_str <- Sys.getenv("EVAL_DATASETS_FILTER", "")
if (nzchar(filter_str)) {
  wanted <- strsplit(filter_str, "[, ]+")[[1]]
  wanted <- wanted[nzchar(wanted)]
  yaml_files <- yaml_files[sub("\\.ya?ml$", "", basename(yaml_files)) %in% wanted]
  if (length(yaml_files) == 0L)
    stop(sprintf("No YAMLs match EVAL_DATASETS_FILTER=%s in %s",
                  filter_str, DATASETS_DIR))
}
if (length(yaml_files) == 0L) stop(sprintf("No dataset YAMLs in %s", DATASETS_DIR))
DATASETS <- list()
for (f in yaml_files) {
  cfg <- yaml::read_yaml(f)
  cat(sprintf("[load] %-25s %s\n", cfg$name, basename(f)))
  DATASETS[[cfg$name]] <- build_dataset(cfg)
}
cat(sprintf("[ready] %d dataset(s): %s\n",
            length(DATASETS), paste(names(DATASETS), collapse = ", ")))
dir.create(dirname(LOG_PATH), recursive = TRUE, showWarnings = FALSE)

# ---- Auth + validation ----------------------------------------------------
require_admin <- function(req) {
  if (!nzchar(ADMIN_TOKEN)) return("scoring disabled (EVAL_ADMIN_TOKEN not set)")
  hdr <- req$HTTP_AUTHORIZATION %||% ""
  if (!identical(hdr, paste0("Bearer ", ADMIN_TOKEN)))
    return("forbidden: missing or invalid admin token")
  NULL
}
parse_trial <- function(ds, k) {
  k <- suppressWarnings(as.integer(k))
  if (is.na(k) || k < 1L || k > ds$info$n_trials) NA_integer_ else k
}
get_dataset <- function(name) DATASETS[[name]]

# ---- Handlers -------------------------------------------------------------
csv_split <- function(part) function(name, k, res) {
  ds <- get_dataset(name)
  if (is.null(ds))   { res$status <- 404; return('{"error":"unknown dataset"}') }
  trial <- parse_trial(ds, k)
  if (is.na(trial))  { res$status <- 400
    return(sprintf('{"error":"trial must be in 1..%d"}', ds$info$n_trials)) }
  ds$splits[[as.character(trial)]][[paste0(part, "_csv")]]
}

csv_test <- function(name, res) {
  ds <- get_dataset(name)
  if (is.null(ds)) { res$status <- 404; return('{"error":"unknown dataset"}') }
  ds$test_csv
}

score_handler <- function(req, res, name, k) {
  ds <- get_dataset(name)
  if (is.null(ds)) { res$status <- 404; return(list(error = "unknown dataset")) }

  err <- require_admin(req)
  if (!is.null(err)) {
    res$status <- if (grepl("disabled", err)) 503 else 403
    return(list(error = err))
  }

  trial <- parse_trial(ds, k)
  if (is.na(trial)) { res$status <- 400
    return(list(error = sprintf("trial must be in 1..%d", ds$info$n_trials))) }

  b <- tryCatch(fromJSON(req$postBody, simplifyVector = TRUE),
                error = function(e) NULL)
  if (is.null(b)) { res$status <- 400; return(list(error = "invalid_json")) }

  id <- b$model_id
  if (!is.character(id) || length(id) != 1L || !nzchar(id)) {
    res$status <- 400; return(list(error = "model_id must be a non-empty string"))
  }

  rid  <- as.character(b$row_ids); pred <- as.numeric(b$predictions)
  n_te <- length(ds$test_y)
  if (length(rid) != n_te || length(pred) != n_te) {
    res$status <- 400
    return(list(error = sprintf("row_ids/predictions must have length %d", n_te)))
  }
  if (anyNA(pred)) {
    res$status <- 400; return(list(error = "predictions must be non-NA"))
  }
  expected <- names(ds$test_y)
  if (!setequal(rid, expected)) {
    res$status <- 400
    return(list(error = "row_ids do not match the (global) test set"))
  }
  ord <- match(expected, rid)
  metric_fn <- METRICS[[ds$cfg$metric]]
  if (is.null(metric_fn)) {
    res$status <- 500
    return(list(error = sprintf("unknown metric: %s", ds$cfg$metric)))
  }
  result <- metric_fn(unname(ds$test_y), pred[ord])

  sid <- paste0("sub_", format(Sys.time(), "%Y%m%dT%H%M%S"), "_", opaque_ids(1))
  rec <- list(submission_id = sid, dataset = name, model_id = id, trial = trial,
              metric = ds$cfg$metric, value = result$value, se = result$se,
              submitted_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"))
  cat(toJSON(rec, auto_unbox = TRUE), "\n", file = LOG_PATH, append = TRUE, sep = "")

  list(submission_id = sid, dataset = name, model_id = id, trial = trial,
       metric = ds$cfg$metric, value = result$value, se = result$se)
}

# ---- Routes ---------------------------------------------------------------
ujson <- serializer_unboxed_json()
csv_s <- serializer_content_type("text/csv")

pr() |>
  pr_get("/healthz", function() list(ok = TRUE), serializer = ujson) |>
  pr_get("/datasets",
         function() lapply(DATASETS, function(d) list(
           name = d$info$name, description = d$info$description,
           metric = d$info$metric, n_trials = d$info$n_trials,
           total_rows = d$info$total_rows, test_rows = d$info$test_rows,
           train_rows = d$info$train_rows, eval_rows = d$info$eval_rows)),
         serializer = ujson) |>
  pr_get("/datasets/<name>/info",
         function(name, res) {
           ds <- get_dataset(name)
           if (is.null(ds)) { res$status <- 404; return(list(error = "unknown dataset")) }
           ds$info
         }, serializer = ujson) |>
  pr_get("/datasets/<name>/splits/<k>/train.csv", csv_split("train"), serializer = csv_s) |>
  pr_get("/datasets/<name>/splits/<k>/eval.csv",  csv_split("eval"),  serializer = csv_s) |>
  pr_get("/datasets/<name>/splits/test.csv",      csv_test,           serializer = csv_s) |>
  pr_post("/datasets/<name>/score/<k>", score_handler, serializer = ujson) |>
  pr_run(host = HOST, port = PORT)
