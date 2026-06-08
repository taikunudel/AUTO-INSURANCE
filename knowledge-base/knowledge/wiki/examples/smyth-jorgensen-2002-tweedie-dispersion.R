# UNVERIFIED — runnable in principle, not executed in this environment.
# Tweedie GLM (single mean model) and DGLM (mean + dispersion).
# Reference: [[wiki/sources/smyth-jorgensen-2002-tweedie-dispersion]]

suppressPackageStartupMessages({
  library(cplm)        # data
  library(statmod)     # tweedie() family + tweedie.profile()
  library(tweedie)     # density / profile likelihood
  library(dglm)        # double GLM
})

# ---- Data ---------------------------------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]          # standard filter — 2,812 rows
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]
test  <- df[-train_idx, ]

# ---- Preprocess (fit on train, apply to test) ---------------------------
train$BLUEBOOK_LOG <- log(train$BLUEBOOK)
train$INCOME_LOG   <- log(train$INCOME + 10)
test$BLUEBOOK_LOG  <- log(test$BLUEBOOK)
test$INCOME_LOG    <- log(test$INCOME + 10)

# Standardize ALL numeric predictors (dataset-independent — detect them from the data,
# do NOT hardcode a column list). Improves IRLS conditioning / convergence, and is
# essential for scale-sensitive methods (see [[wiki/concepts/GroupedElasticNet]]).
predictors <- c("AGE", "BLUEBOOK_LOG", "INCOME_LOG", "MVR_PTS", "AREA")
num_cols <- predictors[vapply(train[predictors], is.numeric, logical(1))]
mu_sc <- sapply(train[num_cols], mean, na.rm = TRUE)
sd_sc <- sapply(train[num_cols], sd,   na.rm = TRUE); sd_sc[sd_sc == 0] <- 1
for (c in num_cols) {
  train[[c]] <- (train[[c]] - mu_sc[c]) / sd_sc[c]
  test[[c]]  <- (test[[c]]  - mu_sc[c]) / sd_sc[c]
}
train$AREA <- factor(train$AREA)
test$AREA  <- factor(test$AREA, levels = levels(train$AREA))   # align levels

# ---- Step 1: Profile p (DO NOT hardcode) --------------------------------
# See [[wiki/concepts/TweedieVariancePowerEstimation]]
prof <- tweedie.profile(
  CLM_AMT ~ AGE + BLUEBOOK_LOG + INCOME_LOG + MVR_PTS + AREA,
  data       = train,
  p.vec      = seq(1.2, 1.8, by = 0.1),
  link.power = 0,
  method     = "inversion",
  do.plot    = FALSE
)
p_hat <- prof$p.max
cat(sprintf("Estimated variance power p = %.3f\n", p_hat))

# ---- Step 2: Tweedie GLM (single mean) ----------------------------------
# IRLS can stop BEFORE convergence on skewed / zero-heavy Tweedie responses when
# glm() runs with its default iteration cap and internally-chosen start: it then
# returns NA/Inf coefficients and worse-than-random predictions (and only WARNS).
# Two knobs guard against it:
#   (1) raise the IRLS iteration cap via glm.control(maxit = ...)
#   (2) give IRLS an explicit starting point via mustart (or warm-start coefficients)
# The needed iteration budget is DATASET-DEPENDENT — there is no universal value.
# Treat the constant below as a STARTING budget and raise it until fit_glm$converged
# is TRUE; do NOT copy a fixed number across datasets.
# See [[wiki/concepts/GeneralizedLinearModels]] (convergence pitfall).
irls_budget <- 100L   # starting budget only — tune upward per dataset until converged
fit_glm <- glm(
  CLM_AMT ~ AGE + BLUEBOOK_LOG + INCOME_LOG + MVR_PTS + AREA,
  data    = train,
  family  = tweedie(var.power = p_hat, link.power = 0),
  mustart = rep(mean(train$CLM_AMT, na.rm = TRUE), nrow(train)),  # sane initialization
  control = glm.control(maxit = irls_budget),
  na.action = na.exclude
)
if (!isTRUE(fit_glm$converged))
  warning("Tweedie GLM did not converge — raise glm.control(maxit) and/or revise mustart/start")
y_hat_glm <- predict(fit_glm, newdata = test, type = "response")

# ---- Step 3: Double GLM (mean + dispersion) -----------------------------
fit_dglm <- dglm(
  formula  = CLM_AMT ~ AGE + BLUEBOOK_LOG + INCOME_LOG + MVR_PTS + AREA,
  dformula = ~ AGE + AREA,                                  # dispersion model
  family   = tweedie(var.power = p_hat, link.power = 0),
  data     = train,
  method   = "reml"
)
y_hat_dglm <- predict(fit_dglm, newdata = test, type = "response")

# ---- Step 4: Compare via Gini -------------------------------------------
# See [[wiki/concepts/GiniIndex]] and [[wiki/sources/frees-meyers-cummings-2011-gini]]
base <- rep(mean(train$CLM_AMT), nrow(test))
g_glm  <- cplm::gini(loss = test$CLM_AMT, score = y_hat_glm,  baseline = base)
g_dglm <- cplm::gini(loss = test$CLM_AMT, score = y_hat_dglm, baseline = base)
cat(sprintf("GLM  Gini = %.3f (SE %.3f)\n",  g_glm$gini,  g_glm$se))
cat(sprintf("DGLM Gini = %.3f (SE %.3f)\n",  g_dglm$gini, g_dglm$se))

# ---- Step 5: Sanity ([[wiki/concepts/LeakageAudit]]) --------------------
stopifnot(abs(mean(y_hat_glm) / mean(test$CLM_AMT) - 1) < 0.10)
# Gini > 0.5 on AutoClaim should trigger a deeper audit.
if (g_glm$gini > 0.5 || g_dglm$gini > 0.5) {
  warning("Implausibly high Gini — run leakage audit")
}
