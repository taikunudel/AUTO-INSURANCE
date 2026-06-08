#!/usr/bin/env bash
# smoke.sh — end-to-end pipeline check: API up -> pull a split -> fit a trivial model
# -> submit predictions on the sealed test set -> read a Gini back.
# Proves the box works before spending a full run.
#
#   ./smoke.sh [dataset]   default: auto_insurance (uses cplm, so no CASdatasets needed)
set -euo pipefail
API="${EVAL_API_URL:-http://localhost:8765}"
TOK="${EVAL_ADMIN_TOKEN:-test-token-12345}"
DS="${1:-auto_insurance}"

echo "1) eval API health"
curl -sf "$API/healthz" >/dev/null && echo "   ok" || { echo "   API down — run ./setup.sh --start-api"; exit 1; }

echo "2) fit a trivial GLM on '$DS' (trial 1) and predict on the sealed test set"
Rscript - "$API" "$DS" <<'RS'
a <- commandArgs(TRUE); api <- a[1]; ds <- a[2]
info <- jsonlite::fromJSON(url(sprintf("%s/datasets/%s/info", api, ds)))
num  <- info$numeric_predictors
tr   <- read.csv(url(sprintf("%s/datasets/%s/splits/1/train.csv", api, ds)))
te   <- read.csv(url(sprintf("%s/datasets/%s/splits/test.csv",    api, ds)))
fit  <- glm(as.formula(paste("y ~", paste(num, collapse=" + "))), data = tr, family = gaussian())
pred <- as.numeric(predict(fit, te, type = "response"))
pred[is.na(pred)] <- mean(pred, na.rm = TRUE)          # keep submission non-NA
body <- jsonlite::toJSON(list(model_id = "smoke", row_ids = te$row_id, predictions = pred),
                         auto_unbox = TRUE)
writeLines(body, "/tmp/smoke_body.json")
cat(sprintf("   trained on %d rows, predicted %d test rows\n", nrow(tr), length(pred)))
RS

echo "3) submit to /score/1 and read the Gini back"
curl -s -X POST "$API/datasets/$DS/score/1" \
  -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
  -d @/tmp/smoke_body.json
echo
echo "If you see a JSON object with a \"value\" (the Gini), the full pipeline works."
