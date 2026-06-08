# Sealed Multi-Dataset Eval API

Black-box train/eval/test loader and metric scorer. Add a YAML, get a sealed leaderboard. Built for use against many datasets with different formats while keeping reserved test labels untouchable by modeling agents.

## Why

Three problems this solves:

1. **Label leakage.** Reserved test labels never leave the API process and are not derivable from anything served. Row IDs in train/eval/test CSVs are opaque random tokens (`r_<hex>`); only the API knows the mapping back to the original data.
2. **Probing as an oracle.** `POST /score` is admin-only (Bearer token). The modeling agent **cannot** call it. The grader runs final scoring after the agent freezes its predictions.
3. **One scorer, N datasets.** Every dataset is a YAML file in `datasets/`. Drop one in, restart, and you have a new endpoint + sealed splits. Metric is pluggable (`gini`, `rmse`, `mae` shipped; add more in `app.R`).

## Endpoints

| Method | Path | Auth | Returns |
|---|---|---|---|
| GET  | `/healthz` | — | liveness |
| GET  | `/datasets` | — | list of registered datasets |
| GET  | `/datasets/<name>/info` | — | manifest: trials, ratios, schema, sizes (no seeds) |
| GET  | `/datasets/<name>/splits/<k>/train.csv` | — | train_k features + `y` |
| GET  | `/datasets/<name>/splits/<k>/eval.csv`  | — | eval_k features + `y` |
| GET  | `/datasets/<name>/splits/test.csv`      | — | global test features (no `y`, no `<k>`) |
| POST | `/datasets/<name>/score/<k>` | Bearer | predictions on global test → `{metric, value, se}` |

`<k>` is an integer in `1..n_trials` (read from `/info`). The test set is **global**: a single sealed holdout carved out once, used to score predictions from any trial's model. The trial index in `/score/<k>` is just an audit tag for which trial-fit model produced these predictions.

### Score request

```json
{
  "model_id": "my_model_v1",
  "row_ids": ["r_ae15...", "r_0599...", ...],
  "predictions": [120.5, 80.1, ...]
}
```

### Score response

```json
{
  "submission_id": "sub_20260503T174517_r_...",
  "dataset": "auto_insurance",
  "model_id": "my_model_v1",
  "trial": 1,
  "metric": "gini",
  "value": 0.3831,
  "se": 0.043
}
```

## Add a dataset (YAML schema)

```yaml
name: auto_insurance
description: cplm AutoClaim, IN_YY == 1 subset

source:
  type: r_package           # r_package | csv | parquet
  package: cplm
  dataset: AutoClaim

filter: "IN_YY == 1"        # optional R expression evaluated in the data

response: CLM_AMT           # column name in the source
response_alias: "y"         # optional rename for the served CSV

predictors:
  numeric: [AGE, BLUEBOOK, ...]
  factor:  [CAR_USE, CAR_TYPE, ...]

metric: gini                # gini | rmse | mae

splits:
  n_trials: 10
  ratios: { train: 0.70, eval: 0.10, test: 0.20 }
```

Drop the file in `datasets/`, restart. Multiple YAMLs = multiple registered datasets.

## Run with Docker

```bash
cd eval-api
docker build -t eval-api:1.0 .

# IMPORTANT: provide an admin token at runtime — without it /score is locked.
TOKEN=$(openssl rand -hex 32)
docker run --rm -p 8765:8000 \
  -e EVAL_ADMIN_TOKEN="$TOKEN" \
  -v eval-api-secrets:/opt/eval-api/secrets \
  --name eval-api eval-api:1.0

echo "admin token: $TOKEN"   # keep this safe; share with the grader only
```

The mounted volume `eval-api-secrets` persists the secret salts so splits stay stable across container restarts.

## Run locally (no Docker)

```bash
cd eval-api
EVAL_ADMIN_TOKEN=$(openssl rand -hex 32) PORT=8765 Rscript app.R
```

Requires `plumber`, `jsonlite`, `yaml`, `cplm` in the local R install.

## Workflow

The agent and the grader play different roles:

- **Agent** (untrusted): GETs `/datasets/<name>/splits/<k>/{train,eval,test}.csv`, fits and tunes locally on train+eval, writes `predictions.json`. Cannot call `/score`.
- **Grader** (holds the admin token): POSTs `predictions.json` to `/score/<k>` with `Authorization: Bearer $TOKEN`, records the returned Gini.

```bash
# grader-side, scoring an agent's submission file
curl -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d @predictions.json \
     http://localhost:8765/datasets/auto_insurance/score/1
```

Audit log: every accepted submission is appended to `logs/submissions.jsonl` with submission_id, dataset, model_id, trial, metric, value, SE, timestamp.

## Configuration

| Env var | Default | Effect |
|---|---|---|
| `EVAL_DATASETS_DIR`  | `datasets`              | Where the YAML registry lives. |
| `EVAL_SECRET_DIR`    | `secrets`               | Persistent salts for split + ID generation. Mount as a volume to keep splits stable. |
| `EVAL_ADMIN_TOKEN`   | (empty — locks `/score`) | Bearer token required by `/score`. |
| `EVAL_LOG_PATH`      | `logs/submissions.jsonl`| Audit log. |
| `PORT`               | `8000`                  | HTTP port. |
| `HOST`               | `0.0.0.0`               | Bind address. |

## Anti-cheat properties

- **Single global test set.** Test rows are carved out **once** at startup. They never appear (with or without labels) in any trial's train/eval. This blocks the cross-trial feature-join attack: an agent cannot recover a test row's `y` by finding the same predictor combination in another trial's train CSV.
- **Test labels are not served and not derivable from served data.** Row IDs are opaque random tokens; the dataset source name and split seeds are NOT in `/info`.
- **`/score` is admin-only.** Without the Bearer token the agent gets HTTP 403; without the env var being set, everyone gets 503.
- **Aggregate-only response.** `/score` returns `{value, se}` and a submission ID. No per-row residuals or rankings.
- **Persistent secret salts.** Generated once on first startup, stored under `EVAL_SECRET_DIR`. Even an attacker with the YAML can't reconstruct splits without the salt.
- **Append-only audit log.** Every grader submission is recorded.

## Not included

- Authentication for the GET endpoints (the agent reads them openly). Add a reverse proxy if you need that.
- TLS — bind to `127.0.0.1` or terminate TLS at a proxy.
- Cross-restart submission counters — the audit log is the durable record.
