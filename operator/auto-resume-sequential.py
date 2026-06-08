#!/usr/bin/env python3
"""
Run openclaw auto-resume loops SEQUENTIALLY (one model at a time).

The zai GLM models share a single zai account quota; running several auto-resume loops
concurrently throttles them. This driver runs each model to 24 SCORED (via auto-resume.py,
which blocks until done/stuck) before starting the next, so only one zai model is ever live.

Order: fewest-remaining first (quick win frees quota for the big ones).
Detached: nohup python3 auto-resume-sequential.py &     Log: /tmp/autoresume_sequential.log
"""
import subprocess, datetime, os

RUNS = [
    # (folder, session-key, model, think_flag, think_label)   -- remaining-to-24 in comment
    ("run-openclaw-glm51-high-run1-wiki0531-20260605-163957",     "agent:main:glm51-run1-r2",     "zai/glm-5.1",     "on", "high"),  # 2
    ("run-openclaw-glm47-high-run1-wiki0531-20260607-021949",     "agent:main:glm47-run1-r2",     "zai/glm-4.7",     "on", "high"),  # 18
    ("run-openclaw-glm5turbo-high-run1-wiki0531-20260607-021930", "agent:main:glm5turbo-run1-r2", "zai/glm-5-turbo", "on", "high"),  # 20
]
LOG = "/tmp/autoresume_sequential.log"

def log(m):
    with open(LOG, "a") as f:
        f.write(f"[{datetime.datetime.utcnow().isoformat()}Z] {m}\n")

log(f"=== sequential runner start: {len(RUNS)} models, one at a time ===")
for i, (d, sk, model, tf, tl) in enumerate(RUNS, 1):
    log(f"--- [{i}/{len(RUNS)}] START {model}  ({d}) ---")
    rc = subprocess.call(["python3", os.path.join(os.path.dirname(os.path.abspath(__file__)), "auto-resume.py"), d, sk, model, tf, tl])
    log(f"--- [{i}/{len(RUNS)}] DONE {model}  rc={rc} ---")
log("=== sequential runner finished all models ===")
