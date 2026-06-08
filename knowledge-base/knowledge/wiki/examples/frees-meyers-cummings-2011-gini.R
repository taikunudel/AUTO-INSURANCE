# UNVERIFIED — runnable in principle, not executed in this environment.
# Ordered Lorenz curve and Gini index for evaluating insurance pricing models.
# Reference: [[wiki/sources/frees-meyers-cummings-2011-gini]]

suppressPackageStartupMessages({
  library(cplm)
})

# ---- Setup --------------------------------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]; test <- df[-train_idx, ]

# Fit two simple pricing models — a constant baseline and a candidate GLM
constant_pred <- rep(mean(train$CLM_AMT), nrow(test))

candidate_fit <- glm(
  CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS,
  data   = train,
  family = quasipoisson(link = "log")     # robust proxy — replace with Tweedie GLM in practice
)
candidate_pred <- predict(candidate_fit, newdata = test, type = "response")

# ---- Single-model Gini vs constant -------------------------------------
# This is what archive/auto-insurance-bench-*/lib/gini.R::gini_insurance() computes.
g_vs_const <- cplm::gini(
  loss     = test$CLM_AMT,
  score    = candidate_pred,
  baseline = constant_pred
)
cat(sprintf("Candidate vs constant: Gini = %.3f (SE %.3f)\n",
            g_vs_const$gini, g_vs_const$se))
# plot(g_vs_const)   # ordered Lorenz curve

# ---- Comparing two competing models (the paper's true use case) --------
# Imagine candidate_pred is a refined score and old_pred is the legacy premium.
old_fit <- glm(CLM_AMT ~ AGE, data = train, family = quasipoisson(link = "log"))
old_pred <- predict(old_fit, newdata = test, type = "response")

g_vs_old <- cplm::gini(
  loss     = test$CLM_AMT,
  score    = candidate_pred,
  baseline = old_pred
)
cat(sprintf("Candidate vs old model: Gini = %.3f (SE %.3f)\n",
            g_vs_old$gini, g_vs_old$se))

# A POSITIVE Gini here means switching to candidate improves separation
# between losses and premiums — i.e., it reduces adverse-selection exposure
# from a competitor that adopts candidate while we stay on old.
# See [[wiki/concepts/AdverseSelection]].

# ---- Minimax framing: which candidate is hardest to attack? ------------
# Loop over all candidates as base and all others as score; report max.
# scores <- list(constant = constant_pred, old = old_pred, candidate = candidate_pred)
# gini_mat <- outer(scores, scores, FUN = Vectorize(function(b, s)
#   cplm::gini(test$CLM_AMT, s, b)$gini))

# ---- Sanity check ------------------------------------------------------
# Intercept-only Gini should be ~ 0
g_intercept <- cplm::gini(
  loss     = test$CLM_AMT,
  score    = constant_pred,
  baseline = constant_pred
)
stopifnot(abs(g_intercept$gini) < 0.05)  # leakage check: see [[wiki/concepts/LeakageAudit]]
