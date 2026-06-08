# UNVERIFIED — runnable in principle, not executed in this environment.
# Gradient tree-boosted Tweedie via TDboost.
# Reference: [[wiki/sources/yang-2016-tdboost]]

suppressPackageStartupMessages({
  library(cplm)
  library(TDboost)
})

# ---- Data + (minimal) preprocessing -------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]; test <- df[-train_idx, ]

# TDboost handles raw numerics and factors directly — no need to scale or dummify.
# We DO need to align factor levels for predict() to work on test.
for (col in c("AREA")) {
  test[[col]] <- factor(test[[col]], levels = levels(factor(train[[col]])))
}

# ---- Fit ----------------------------------------------------------------
set.seed(1001)
fit <- TDboost(
  formula      = CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS + TRAVTIME +
                            NPOLICY + KIDSDRIV + HOMEKIDS + AREA,
  data         = train,
  distribution = list(name = "EDM", alpha = 1.5),   # alpha = variance power p
  n.trees      = 3000,                              # max; pick best via CV
  interaction.depth = 3,
  shrinkage    = 0.005,                              # paper-recommended
  bag.fraction = 0.5,
  cv.folds     = 5,
  keep.data    = FALSE,
  verbose      = FALSE
)

# ---- Pick the CV-optimal number of trees (DO NOT predict at fit$n.trees) ----
best_iter <- TDboost.perf(fit, method = "cv", plot.it = FALSE)
cat(sprintf("CV-optimal trees: %d (of %d)\n", best_iter, fit$n.trees))

# ---- Predict ------------------------------------------------------------
y_hat  <- predict(fit, newdata = test, n.trees = best_iter, type = "response")
y_test <- test$CLM_AMT

# ---- Interpret ----------------------------------------------------------
ri <- relative.influence(fit, n.trees = best_iter)
cat("Top 5 features by relative influence:\n")
print(head(sort(ri, decreasing = TRUE), 5))

# Partial-dependence on AGE (sanity-check monotonicity for pricing)
# plot(fit, i.var = "AGE", n.trees = best_iter)

# ---- Evaluate -----------------------------------------------------------
base <- rep(mean(train$CLM_AMT), length(y_test))
g    <- cplm::gini(loss = y_test, score = y_hat, baseline = base)
cat(sprintf("TDboost Gini = %.3f (SE %.3f)\n", g$gini, g$se))

# Sanity ([[wiki/concepts/CalibrationPlots]] + [[wiki/concepts/LeakageAudit]])
stopifnot(abs(mean(y_hat) / mean(y_test) - 1) < 0.10)
if (g$gini > 0.5) warning("Implausible Gini — run leakage audit")
