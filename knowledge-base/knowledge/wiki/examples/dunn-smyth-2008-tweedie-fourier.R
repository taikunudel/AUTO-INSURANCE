# UNVERIFIED — runnable in principle, not executed in this environment.
# Tweedie density evaluation + variance-power profile likelihood.
# Reference: [[wiki/sources/dunn-smyth-2008-tweedie-fourier]]

suppressPackageStartupMessages({
  library(cplm)
  library(tweedie)
  library(statmod)
})

# ---- Density evaluation -------------------------------------------------
# Evaluate Tweedie density at a small grid.
# Both methods should agree away from p = 1, 2 boundaries.
y_grid <- c(0, 0.5, 1, 2, 5)
d_series    <- dtweedie(y_grid, mu = 1, phi = 1, power = 1.5)     # series method
d_inversion <- tweedie::dtweedie.inversion(y_grid, power = 1.5,
                                            mu = 1, phi = 1)      # Fourier inversion
print(rbind(series = d_series, inversion = d_inversion))
# Disagreement > 1e-6 between methods near boundaries (p close to 1 or 2)
# indicates one of the two is failing; use whichever is appropriate for your
# (p, y, phi) region.

# ---- Profile likelihood for p (the main use case) -----------------------
data("AutoClaim", package = "cplm")
df <- AutoClaim[AutoClaim$IN_YY == 1, ]
set.seed(1001)
train_idx <- sample.int(nrow(df), size = nrow(df) %/% 2)
train <- df[train_idx, ]

# Coarse grid first
prof_coarse <- tweedie.profile(
  formula    = CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS,
  data       = train,
  p.vec      = seq(1.1, 1.9, by = 0.1),
  link.power = 0,
  method     = "inversion",                 # safer near p ~ 1.5
  do.plot    = FALSE
)
cat(sprintf("Coarse profile: p_hat = %.3f, log-lik = %.2f\n",
            prof_coarse$p.max, prof_coarse$L.max))

# Refine near optimum
prof_fine <- tweedie.profile(
  formula    = CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS,
  data       = train,
  p.vec      = seq(prof_coarse$p.max - 0.1, prof_coarse$p.max + 0.1, by = 0.02),
  link.power = 0,
  method     = "inversion",
  do.plot    = FALSE
)
cat(sprintf("Refined p_hat = %.3f, 95%% CI = [%.3f, %.3f]\n",
            prof_fine$p.max, prof_fine$ci[1], prof_fine$ci[2]))

# ---- Use the estimated p in a downstream model --------------------------
# See [[wiki/concepts/TweedieVariancePowerEstimation]] for why hardcoding p is harmful.
fit <- glm(
  CLM_AMT ~ AGE + BLUEBOOK + INCOME + MVR_PTS,
  data   = train,
  family = tweedie(var.power = prof_fine$p.max, link.power = 0)
)
cat(sprintf("GLM with estimated p = %.3f fitted; deviance = %.1f\n",
            prof_fine$p.max, fit$deviance))
