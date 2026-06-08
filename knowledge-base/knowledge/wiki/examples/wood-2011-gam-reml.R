# UNVERIFIED — runnable in principle, not executed in this environment.
# Tweedie GAM via mgcv with REML smoothness selection.
# Reference: [[wiki/sources/wood-2011-gam-reml]]

suppressPackageStartupMessages({
  library(cplm)
  library(mgcv)
})

# ---- Data ---------------------------------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]; test <- df[-train_idx, ]

# Align factor levels — mgcv errors on unseen levels in test
for (col in c("AREA")) {
  train[[col]] <- factor(train[[col]])
  test[[col]]  <- factor(test[[col]], levels = levels(train[[col]]))
}

# ---- Fit GAM with smooths on continuous predictors ----------------------
# tw() (lowercase) estimates p automatically — preferred over Tweedie(p=fixed).
# method="REML" is the paper's main point: never use GCV.Cp default.
fit <- gam(
  CLM_AMT ~ s(AGE,      k = 10) +
            s(BLUEBOOK, k = 10) +
            s(INCOME,   k = 10) +
            s(TRAVTIME, k = 10) +
            s(MVR_PTS,  k = 5)  +     # smaller k — integer-valued, few levels
            AREA,                      # factor enters directly, NOT inside s()
  data    = train,
  family  = tw(),
  method  = "REML",
  select  = TRUE                       # shrinkage-based variable selection
)

# ---- Diagnostics (k-index, residual patterns) ---------------------------
gam.check(fit)                          # if k-index << 1 anywhere, raise k

# Concurvity check — analog of collinearity for smooths
# concurvity(fit)   # uncomment to inspect

# ---- Predict + evaluate -------------------------------------------------
y_hat  <- predict(fit, newdata = test, type = "response")
y_test <- test$CLM_AMT

base <- rep(mean(train$CLM_AMT), length(y_test))
g    <- cplm::gini(loss = y_test, score = y_hat, baseline = base)
cat(sprintf("GAM Gini = %.3f (SE %.3f), est. Tweedie p = %.3f\n",
            g$gini, g$se, fit$family$getTheta(TRUE)))

# Smooth-effect plots (visual interpretation)
# plot(fit, pages = 1, shade = TRUE)

# Sanity
stopifnot(abs(mean(y_hat) / mean(y_test) - 1) < 0.10)
if (g$gini > 0.5) warning("Implausible Gini — run leakage audit")
