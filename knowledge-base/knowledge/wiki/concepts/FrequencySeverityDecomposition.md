---
title: "Frequency-Severity Decomposition"
type: concept
tags: [domain, actuarial]
sources: [delong-lindholm-wuthrich-2021-tweedie, smyth-jorgensen-2002-tweedie-dispersion]
last_updated: 2026-05-15
---

## Definition
The actuarial convention of decomposing total claim losses into two independently-modeled components: *frequency* (how often claims occur, typically Poisson) and *severity* (how large claims are when they occur, typically gamma). Pure premium = frequency × severity. The decomposition exposes that some risk factors (e.g., MVR points) act primarily on frequency while others (e.g., vehicle book value) act primarily on severity — information lost in a single Tweedie GLM.

## Why It Matters in Practice
- Standard industry parametrization for auto, home, and many specialty lines
- Diagnostically valuable: a single bad coefficient is easier to detect when modeled separately. In a Tweedie GLM, frequency- and severity-driven changes are intertwined.
- Required when claim counts AND individual claim amounts are both observed
- Recommended in [[delong-lindholm-wuthrich-2021-tweedie]] over Tweedie DGLM when the goal is robust, interpretable pricing — especially for neural-network extensions where Tweedie loss has known optimization instabilities

## How to Handle in Code
```R
# Frequency: Poisson with exposure offset
fit_freq <- glm(N ~ AGE + AREA + MVR_PTS + offset(log(EXPOSURE)),
                data = train, family = poisson(link = "log"))

# Severity: conditional on N > 0, weighted by N
fit_sev <- glm(CLM_AMT_PER_CLAIM ~ AGE + AREA + BLUEBOOK,
               data = subset(train, N > 0),
               family = Gamma(link = "log"),
               weights = N)

# Pure premium for prediction
pp <- predict(fit_freq, test, type = "response") *
      predict(fit_sev,  test, type = "response")
```
See `[[examples/delong-lindholm-wuthrich-2021-tweedie]]` for the full pipeline.

## Common Mistakes
- **Computing severity on raw CLM_AMT instead of CLM_AMT / N** — fits the *total* claim loss conditional on having any, which is a different (and less interpretable) thing
- **Forgetting `weights = N` in severity** — high-frequency policies become silently underweighted
- **Including zero-claim rows in severity** — gamma is undefined at zero; subset to `N > 0` first
- **Different covariate sets for frequency vs severity that don't match the business logic** — the decomposition's value is showing where they differ; consistent covariates mask that
- **Adding instead of multiplying for pure premium** — common slip; the two predictions combine multiplicatively

## Sources
- [[delong-lindholm-wuthrich-2021-tweedie]] — argues for Poisson-Gamma over Tweedie DGLM
- [[smyth-jorgensen-2002-tweedie-dispersion]] — describes when Tweedie DGLM substitutes
