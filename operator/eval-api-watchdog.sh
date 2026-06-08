#!/bin/bash
WS="$(cd "$(dirname "$0")/.." && pwd)"
while true; do
  if ! curl -s --max-time 5 http://localhost:8765/healthz 2>/dev/null | grep -q '"ok":true'; then
    cd "$WS/evaluator"
    EVAL_ADMIN_TOKEN=test-token-12345 PORT=8765 HOST=0.0.0.0 nohup Rscript app.R >> /tmp/eval_api_wd_restart.log 2>&1 &
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] API was down -> restarted" >> /tmp/eval_api_watchdog.log
    sleep 25
  fi
  sleep 60
done
