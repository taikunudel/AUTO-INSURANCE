# Agent Guide

You are a modeling agent. The eval API is your **only** source of data. You can read `train` and `eval` (with labels) and `test` (features only). You **cannot** score against test — the `/score` endpoint requires an admin token you do not have. When you finish training, hand your predictions to the grader; they score them.

## Workflow

```
1. GET  /datasets                          → list of available datasets
2. GET  /datasets/<name>/info              → schema, n_trials, sizes, metric
3. GET /datasets/<name>/splits/test.csv         → global test features (no y, no k)
4. for k in 1..n_trials:
     GET  /datasets/<name>/splits/<k>/train.csv  → train_k features + y
     GET  /datasets/<name>/splits/<k>/eval.csv   → eval_k features + y
     fit on train_k, tune on eval_k, predict on the GLOBAL test set
     write predictions to predictions_<name>_<k>.json
5. Hand all predictions JSON files to the grader.

The test set is the SAME for every trial. Different trials reshuffle only train/eval, so predictions from N trial-fit models give N estimates of how well that model family scores on the same sealed test.
```

## CSV schema

- `train.csv` and `eval.csv`: predictor columns + the response column (its name is in `info.response_var`, usually `y`) + `row_id`. **Drop `row_id` before fitting** — it's a unique token per row, useless as a predictor and breaks `predict()` if R treats it as a factor.
- `test.csv`: predictor columns + `row_id` only — **no response**. Same warning: drop `row_id` before passing to `predict()`, then attach it back to the predictions for submission.
- `row_id` is an opaque token like `r_a8f9c2b1...` — do not assume any structure or order. Test row_ids are stable across trials. Train/eval row_ids are unique per (trial, partition).

## Predictions file

Write one JSON per `(dataset, trial)`:

```json
{
  "model_id": "my_model_v1",
  "row_ids": ["r_ae15...", "r_0599...", ...],
  "predictions": [120.5, 80.1, ...]
}
```

Constraints:
- `row_ids` and `predictions` must each be `n_test` long (read from `/info`).
- `row_ids` must be the same set as the `row_id` column in `test.csv` for that trial. Order doesn't matter — the grader's API matches them.
- All `predictions` must be finite numbers.
- `model_id` is your label; pick a stable name.

## What you cannot do

- You cannot retrieve `y` for any test row. There is no endpoint that returns it.
- You cannot call `/score` — it returns HTTP 403 without the admin token.
- You cannot probe the test set repeatedly to optimize against the metric. Final scoring is one-shot, done by the grader.

## Recommended pattern (R)

```r
library(jsonlite); library(curl); library(statmod)
base <- Sys.getenv("EVAL_API_URL", "http://localhost:8765")
ds   <- "auto_insurance"
info <- fromJSON(paste0(base, "/datasets/", ds, "/info"))

test_ <- read.csv(sprintf("%s/datasets/%s/splits/test.csv", base, ds))
test_ids <- as.character(test_$row_id); test_$row_id <- NULL  # drop before predict

for (k in seq_len(info$n_trials)) {
  train <- read.csv(sprintf("%s/datasets/%s/splits/%d/train.csv", base, ds, k))
  eval_ <- read.csv(sprintf("%s/datasets/%s/splits/%d/eval.csv",  base, ds, k))
  train$row_id <- NULL; eval_$row_id <- NULL

  # ... preprocess, fit on train, tune on eval, predict on test ...
  preds <- predict(my_model, newdata = test_, type = "response")

  out <- list(model_id = "my_glm_v1",
              row_ids = test_ids,
              predictions = unname(preds))
  write(toJSON(out, auto_unbox = TRUE),
        sprintf("predictions_%s_%d.json", ds, k))
}
```

## Recommended pattern (Python)

```python
import requests, pandas as pd, io, json, os
base = os.environ.get("EVAL_API_URL", "http://localhost:8765")
ds   = "auto_insurance"
info = requests.get(f"{base}/datasets/{ds}/info").json()

def fetch(path):
    return pd.read_csv(io.StringIO(requests.get(f"{base}{path}").text))

test_ = fetch(f"/datasets/{ds}/splits/test.csv")
test_ids = test_["row_id"].tolist()
test_X = test_.drop(columns=["row_id"])

for k in range(1, info["n_trials"] + 1):
    train = fetch(f"/datasets/{ds}/splits/{k}/train.csv").drop(columns=["row_id"])
    eval_ = fetch(f"/datasets/{ds}/splits/{k}/eval.csv").drop(columns=["row_id"])

    # ... preprocess, fit on train, tune on eval, predict on test ...
    preds = my_model.predict(test_X)

    with open(f"predictions_{ds}_{k}.json", "w") as f:
        json.dump({"model_id": "my_model_v1",
                   "row_ids": test_ids,
                   "predictions": preds.tolist()}, f)
```

## Schema reference

Get it from `/datasets/<name>/info`. Example for `auto_insurance` (defaults):

- `total_rows`: 2812
- `n_trials`: 10
- `ratios`: `{train: 0.70, eval: 0.10, test: 0.20}`
- `test_rows`: 562 (global, fixed)
- `train_rows` / `eval_rows`: 1968 / 282 per trial
- `response_var`: `"y"` (insurance claim amount, dollars; non-negative, ~68% zeros)
- `numeric_predictors`: AGE, BLUEBOOK, HOMEKIDS, KIDSDRIV, INCOME, MVR_PTS, NPOLICY, TRAVTIME, YOJ, HOME_VAL
- `factor_predictors`: CAR_USE, CAR_TYPE, RED_CAR, REVOLKED, GENDER, MARRIED, PARENT1, JOBCLASS, MAX_EDUC, AREA
- `metric`: `gini` (computed by `cplm::gini()` with constant baseline `M(x)=1`)

Notes on the data:
- `BLUEBOOK` and `INCOME` are heavy-tailed; consider `log(BLUEBOOK)` and `log(INCOME + 10)`.
- `YOJ` and `HOME_VAL` contain ~5% NAs; impute on train and reuse for eval/test.
- `CAR_TYPE` (6 levels), `JOBCLASS` (8 levels), `MAX_EDUC` (5 levels) are multi-level factors; the rest are binary.
