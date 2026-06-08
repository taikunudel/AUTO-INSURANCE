# UNVERIFIED — runnable in principle, not executed in this environment.
# Grouped elastic net for Tweedie via HDtweedie.
# Reference: [[wiki/sources/qian-2016-hdtweedie]]

suppressPackageStartupMessages({
  library(cplm)
  library(HDtweedie)
})

# ---- Data + preprocessing -----------------------------------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]; test <- df[-train_idx, ]

train$BLUEBOOK_LOG <- log(train$BLUEBOOK)
train$INCOME_LOG   <- log(train$INCOME + 10)
test$BLUEBOOK_LOG  <- log(test$BLUEBOOK)
test$INCOME_LOG    <- log(test$INCOME + 10)
# Standardize ALL numeric predictors (center + unit variance) BEFORE building x.
# HDtweedie's group penalty is scale-sensitive: predictors left on different scales can
# drive the path to keep only 1-2 groups (n_active collapses -> near-random Gini).
# DATASET-INDEPENDENT: detect numeric predictors from the data; never hardcode a list.
# See [[wiki/concepts/GroupedElasticNet]] (scaling pitfall).
predictors <- c("AGE", "BLUEBOOK_LOG", "INCOME_LOG", "MVR_PTS", "AREA")
num_cols <- predictors[vapply(train[predictors], is.numeric, logical(1))]
mu_sc <- sapply(train[num_cols], mean, na.rm = TRUE)
sd_sc <- sapply(train[num_cols], sd,   na.rm = TRUE); sd_sc[sd_sc == 0] <- 1
for (c in num_cols) {
  train[[c]] <- (train[[c]] - mu_sc[c]) / sd_sc[c]
  test[[c]]  <- (test[[c]]  - mu_sc[c]) / sd_sc[c]
}

# ---- Build design matrix (no intercept, no factor cols) -----------------
# HDtweedie expects a numeric matrix — see [[wiki/concepts/GroupedElasticNet]] pitfalls.
form  <- ~ AGE + BLUEBOOK_LOG + INCOME_LOG + MVR_PTS + AREA - 1   # -1 drops intercept
X_train <- model.matrix(form, data = train)
X_test  <- model.matrix(form, data = test)

# Align test columns to train (drops unseen factor levels — silent crash source)
X_test <- X_test[, colnames(X_train), drop = FALSE]

y_train <- train$CLM_AMT
y_test  <- test$CLM_AMT

# ---- Build grouping vector: ALL DUMMIES OF ONE FACTOR IN ONE GROUP ------
# Numeric columns get their own group; all AREA-dummies share a group.
# A naive `group <- 1:ncol(X_train)` collapses to ordinary elastic net.
col_groups <- ifelse(grepl("^AREA", colnames(X_train)), "AREA",
                     colnames(X_train))
group_vec  <- as.integer(factor(col_groups, levels = unique(col_groups)))

# ---- Fit (5-fold CV) ----------------------------------------------------
set.seed(1001)
cv_fit <- cv.HDtweedie(
  x      = X_train,
  y      = y_train,
  group  = group_vec,
  p      = 1.5,                                # estimate via tweedie.profile in practice
  alpha  = 0.7,                                # grouped elastic net
  nfolds = 5
)

# ---- Predict (REQUIRES s = "lambda.min") -------------------------------
y_hat <- predict(cv_fit, newx = X_test, s = "lambda.min", type = "response")
y_hat <- as.numeric(y_hat)

beta_min <- coef(cv_fit, s = "lambda.min")
n_active <- sum(beta_min != 0) - 1   # exclude intercept
# Self-check: a collapse to ~1-2 active groups with near-random Gini is the fingerprint
# of unscaled / ill-conditioned inputs — standardize numerics (above) and refit.
if (n_active <= 2)
  warning("Grouped-lasso kept <=2 active groups — suspect unscaled inputs; standardize and refit")

# ---- Evaluate -----------------------------------------------------------
base <- rep(mean(y_train), length(y_test))
g    <- cplm::gini(loss = y_test, score = y_hat, baseline = base)
cat(sprintf("HDtweedie Gini = %.3f (SE %.3f), %d active coeffs\n",
            g$gini, g$se, n_active))

# Sanity ([[wiki/concepts/LeakageAudit]])
if (g$gini > 0.5) warning("Implausible Gini — run leakage audit")
