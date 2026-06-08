# UNVERIFIED — runnable in principle, not executed in this environment.
# Frequency-Severity Poisson-Gamma vs Tweedie DGLM, on AutoClaim.
# Reference: [[wiki/sources/delong-lindholm-wuthrich-2021-tweedie]]
# Concept:   [[wiki/concepts/FrequencySeverityDecomposition]]

suppressPackageStartupMessages({
  library(cplm)
  library(statmod)
})

# ---- Data ---------------------------------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]; test <- df[-train_idx, ]

# AutoClaim doesn't ship a clean per-claim severity column, so we derive an
# approximation: when CLM_FREQ5 > 0, average claim size ≈ CLM_AMT / CLM_FREQ5.
# This is "claims in past 5 years" — a proxy. In production data, use the
# actual N and per-claim Z_j vectors.
train$N           <- train$CLM_FREQ5                    # claim count proxy
train$AVG_SIZE    <- ifelse(train$N > 0, train$CLM_AMT / train$N, NA)
test$N            <- test$CLM_FREQ5
test$AVG_SIZE     <- ifelse(test$N > 0,  test$CLM_AMT  / test$N,  NA)

# Align factor levels
for (col in c("AREA")) {
  train[[col]] <- factor(train[[col]])
  test[[col]]  <- factor(test[[col]], levels = levels(train[[col]]))
}

# ---- A) Poisson-Gamma (paper's recommended industry baseline) ----------

# A.1) Frequency — Poisson GLM
# If you had an EXPOSURE column, use: + offset(log(EXPOSURE))
# AutoClaim doesn't ship one, so we treat exposure as 1 (constant).
fit_freq <- glm(
  N ~ AGE + BLUEBOOK + INCOME + MVR_PTS + AREA,
  data   = train,
  family = poisson(link = "log")
)

# A.2) Severity — Gamma GLM, conditional on N > 0, weighted by N
train_sev <- subset(train, N > 0 & !is.na(AVG_SIZE))
fit_sev <- glm(
  AVG_SIZE ~ AGE + BLUEBOOK + INCOME + MVR_PTS + AREA,
  data    = train_sev,
  family  = Gamma(link = "log"),
  weights = N
)

# Pure premium = frequency × severity (per unit exposure)
pp_pg <- predict(fit_freq, newdata = test, type = "response") *
         predict(fit_sev,  newdata = test, type = "response")

# ---- B) Single Tweedie GLM (the alternative parametrization) -----------
fit_tw <- glm(
  CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS + AREA,
  data   = train,
  family = tweedie(var.power = 1.5, link.power = 0)
)
pp_tw <- predict(fit_tw, newdata = test, type = "response")

# ---- Compare via Gini --------------------------------------------------
base <- rep(mean(train$CLM_AMT), nrow(test))
g_pg <- cplm::gini(loss = test$CLM_AMT, score = pp_pg, baseline = base)
g_tw <- cplm::gini(loss = test$CLM_AMT, score = pp_tw, baseline = base)

cat(sprintf("Poisson-Gamma Gini = %.3f (SE %.3f)\n", g_pg$gini, g_pg$se))
cat(sprintf("Tweedie GLM   Gini = %.3f (SE %.3f)\n", g_tw$gini, g_tw$se))

# The paper's argument is NOT that one always wins on Gini — they're
# mathematically related — but that Poisson-Gamma is more *robust* in
# calibration and easier to extend (neural networks, mixed effects).

# Sanity
stopifnot(abs(mean(pp_pg) / mean(test$CLM_AMT) - 1) < 0.20)
stopifnot(abs(mean(pp_tw) / mean(test$CLM_AMT) - 1) < 0.20)
