#!/usr/bin/env bash
# setup.sh — bootstrap the environment to run the auto-insurance benchmark.
#
# Installs the R packages (eval API + modeling), including CASdatasets from its
# off-CRAN repo (it feeds 5 of the 6 datasets), verifies every dataset loads, and
# optionally starts the eval API.
#
#   ./setup.sh              install + verify
#   ./setup.sh --start-api  also start the eval API on :8765
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "== 1/4  R present? =="
command -v Rscript >/dev/null || { echo "  R not found — install R first (https://cran.r-project.org)"; exit 1; }
Rscript -e 'cat("  R", as.character(getRversion()), "\n")'

echo "== 2/4  CRAN packages (eval API + modeling) =="
Rscript -e '
pkgs <- c("plumber","jsonlite","yaml","cplm",                       # eval API + AutoClaim data
          "mgcv","HDtweedie","TDboost","tweedie","statmod","dglm")  # modeling
need <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(need)) { cat("  installing:", paste(need, collapse=", "), "\n")
  install.packages(need, repos="https://cloud.r-project.org") }
cat("  CRAN packages OK\n")'

echo "== 3/4  CASdatasets (NOT on CRAN — 5 of 6 datasets) =="
Rscript -e '
if (!"CASdatasets" %in% rownames(installed.packages())) {
  ok <- tryCatch({ install.packages("CASdatasets", repos="http://cas.uqam.ca/pub/R/")
                   "CASdatasets" %in% rownames(installed.packages()) },
                 error = function(e) FALSE)
  if (!isTRUE(ok)) {
    cat("  UQAM repo failed — falling back to GitHub (dutangc/CASdatasets)\n")
    if (!"remotes" %in% rownames(installed.packages()))
      install.packages("remotes", repos="https://cloud.r-project.org")
    remotes::install_github("dutangc/CASdatasets")
  }
}
stopifnot("CASdatasets" %in% rownames(installed.packages()))
cat("  CASdatasets OK\n")'

echo "== 4/4  verify every dataset loads =="
Rscript -e '
specs <- list(c("CASdatasets","ausprivauto0405"), c("cplm","AutoClaim"),
              c("CASdatasets","beMTPL97"),         c("CASdatasets","freMTPL2freq"),
              c("CASdatasets","sgautonb"),         c("CASdatasets","swautoins"))
bad <- 0
for (s in specs) { e <- new.env()
  ok <- tryCatch({ suppressWarnings(do.call(library, list(s[1], character.only=TRUE, quietly=TRUE)))
                   suppressWarnings(data(list=s[2], package=s[1], envir=e)); exists(s[2], e) },
                 error = function(x) FALSE)
  cat(sprintf("  %-14s %-16s %s\n", s[1], s[2], if (ok) "OK" else "MISSING")); if (!ok) bad <- bad+1 }
if (bad) quit(status=1)'

echo ""
echo "Environment ready.  Next:  cp .env.example .env  (add your token + API keys),  then  ./smoke.sh"

if [ "${1:-}" = "--start-api" ]; then
  echo "== starting eval API on :8765 =="
  ( cd "$HERE/evaluator" \
      && EVAL_ADMIN_TOKEN="${EVAL_ADMIN_TOKEN:-test-token-12345}" PORT=8765 HOST=0.0.0.0 \
         nohup Rscript app.R >/tmp/eval_api.log 2>&1 & )
  sleep 8
  if curl -sf localhost:8765/healthz >/dev/null; then echo "  API up at http://localhost:8765"
  else echo "  API not up yet — check /tmp/eval_api.log"; fi
fi
