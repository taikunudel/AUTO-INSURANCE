# UNVERIFIED — runnable in principle, not executed in this environment.
# Tweedie compound-Poisson via cplm (GLM, mixed, and Bayesian variants).
# Reference: [[wiki/sources/zhang-2013-cplm]]

suppressPackageStartupMessages({
  library(cplm)
})

# ---- Data ---------------------------------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]; test <- df[-train_idx, ]

# Align factor levels
for (col in c("AREA")) {
  train[[col]] <- factor(train[[col]])
  test[[col]]  <- factor(test[[col]], levels = levels(train[[col]]))
}

# ---- 1) Tweedie GLM (estimates p by default) ----------------------------
# This is the cleanest way to fit a Tweedie GLM with p estimated from data.
fit_glm <- cpglm(
  CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS + AREA,
  data = train,
  link = "log"
)
cat(sprintf("cpglm: p = %.3f, dispersion phi = %.3f\n",
            fit_glm@p, fit_glm@phi))

y_hat_glm <- predict(fit_glm, newdata = test, type = "response")

# ---- 2) Tweedie GLMM (random intercept by AREA) ------------------------
# When grouping structure matters (e.g., regional risk pools).
fit_mm <- cpglmm(
  CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS + (1 | AREA),
  data = train,
  link = "log",
  optimizer = "nlminb",
  nAGQ = 1                              # 1 = Laplace; 5–10 = AGQ for more accuracy
)
y_hat_mm <- predict(fit_mm, newdata = test, type = "response")

# ---- 3) Bayesian Tweedie GLMM ------------------------------------------
# Optional / expensive — uncomment to run MCMC
# fit_bayes <- bcplm(
#   CLM_AMT ~ AGE + BLUEBOOK + (1 | AREA),
#   data     = train,
#   n.chains = 3,
#   n.iter   = 10000,
#   n.burnin = 2000
# )
# summary(fit_bayes)

# ---- Evaluate via Gini --------------------------------------------------
# cplm::gini is the canonical implementation of [[wiki/concepts/GiniIndex]].
base <- rep(mean(train$CLM_AMT), nrow(test))
g_glm <- cplm::gini(loss = test$CLM_AMT, score = y_hat_glm, baseline = base)
g_mm  <- cplm::gini(loss = test$CLM_AMT, score = y_hat_mm,  baseline = base)

cat(sprintf("cpglm  Gini = %.3f (SE %.3f), est. p = %.3f\n",
            g_glm$gini, g_glm$se, fit_glm@p))
cat(sprintf("cpglmm Gini = %.3f (SE %.3f), est. p = %.3f\n",
            g_mm$gini,  g_mm$se,  fit_mm@p))

# Sanity
stopifnot(abs(mean(y_hat_glm) / mean(test$CLM_AMT) - 1) < 0.10)
if (g_glm$gini > 0.5 || g_mm$gini > 0.5) {
  warning("Implausible Gini — run leakage audit ([[wiki/concepts/LeakageAudit]])")
}
