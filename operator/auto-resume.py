#!/usr/bin/env python3
"""
Generalized auto-resume loop for openclaw benchmark runs that fall short of 24 SCORED
combos (6 datasets x 4 models, each with a non-NA mean_eval_gini).

openclaw runs the agent inside its gateway; the agent gets cut by openclaw's ~10-min
provider RPC timeout mid-run (external, not the agent's fault), and some also self-stop
early. Each resume continues from prior ON-DISK progress, so we re-resume until 24/24
SCORED, or progress genuinely stalls. Self-heals the eval API.

Completion is measured as SCORED combos (rows with a real mean_eval_gini), NOT row
count -- a run can have 24 rows but many NA (e.g. eval failed for 3 of 4 models).

Rate-limit aware: if a resume turn ends on a provider rate-limit ("API rate limit
reached"), back off and retry instead of counting it as a stall. Run models ONE AT A
TIME (see auto-resume-sequential.py) so a shared account quota isn't hit concurrently.

Usage:
  python3 auto-resume.py <run_folder> <session-key> <provider/model> [think_flag] [think_label]
    think_flag  = openclaw --thinking value        (default xhigh; zai GLM need "on")
    think_label = env THINKING_LEVEL roster label  (default = think_flag; zai GLM = "high")

Detached: nohup python3 auto-resume.py ... &     Log: /tmp/autoresume_<sk>.log
"""
import subprocess, time, os, glob, csv, json, datetime, sys

WS  = os.environ.get("WORKSPACE") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
D   = sys.argv[1]
SK  = sys.argv[2]
MODEL = sys.argv[3]
THINK_FLAG  = sys.argv[4] if len(sys.argv) > 4 else "xhigh"
THINK_LABEL = sys.argv[5] if len(sys.argv) > 5 else THINK_FLAG
SESSIONS = os.path.expanduser("~/.openclaw/agents/main/sessions/sessions.json")
LOG = "/tmp/autoresume_" + SK.replace(":", "_").replace("/", "_") + ".log"
TARGET = 24
MAX_CYCLES, STUCK_LIMIT, RL_LIMIT = 80, 3, 20
MSG = ("Your benchmark run is INCOMPLETE and stopped early. Existing work is intact in " + D +
       " - do NOT wipe or restart it. Completion = ALL 6 datasets (ausprivauto, auto_insurance, "
       "bemtpl97, fremtpl2, sgautonb, swautoins) x ALL 4 models (tweedie_gam, grplasso, grpnet, "
       "tdboost) = 24 rows in results/summary.csv, each with a REAL numeric mean_eval_gini (not NA, "
       "not missing). Read results/summary.csv, find every combo that is missing or shows NA eval "
       "gini, and finish it: fit the model and submit predictions to the eval API for its gini. If a "
       "model errors or its eval gini is NA, read the R warnings/errors and fix the root cause before "
       "moving on. Keep each turn SHORT so progress checkpoints to disk before any timeout. Continue "
       "until all 24 combos have a real eval gini.")
os.chdir(WS)

def log(m):
    with open(LOG, "a") as f:
        f.write(f"[{datetime.datetime.utcnow().isoformat()}Z] {m}\n")

def scored():
    """Combos with a real (non-NA) mean_eval_gini in summary.csv."""
    s = os.path.join(D, "results", "summary.csv")
    if not os.path.exists(s): return 0
    n = 0
    try:
        with open(s, newline="") as f:
            for row in csv.DictReader(f):
                g = (row.get("mean_eval_gini") or "").strip().strip('"')
                if g and g.upper() not in ("NA", "NAN", ""):
                    n += 1
    except: pass
    return n

def trials():
    return len(glob.glob(os.path.join(D, "results", "**", "trial_*.csv"), recursive=True))

def file_count():
    return len(glob.glob(os.path.join(D, "**", "*"), recursive=True))

def session_status():
    try:
        d = json.load(open(SESSIONS)); v = d.get(SK, {})
        return (v.get("status") if isinstance(v, dict) else str(v)) or "?"
    except: return "?"

def recent_activity(window=200):
    now = time.time()
    for p in glob.glob(os.path.join(D, "**", "*"), recursive=True):
        try:
            if now - os.path.getmtime(p) < window: return True
        except: pass
    return False

def is_working():
    return session_status() == "running" or recent_activity(200)

def rate_limited():
    """True if the last resume turn ended on a provider rate-limit (transient)."""
    rl = LOG.replace(".log", "_resume.log")
    if not os.path.exists(rl): return False
    try:
        with open(rl) as f:
            tail = f.read()[-3000:].lower()
        return "rate limit reached" in tail or ("failovererror" in tail and "rate limit" in tail)
    except: return False

def api_ok():
    r = subprocess.run(["curl","-s","--max-time","5","http://localhost:8765/healthz"], capture_output=True, text=True)
    return '"ok":true' in r.stdout

def ensure_api():
    if api_ok(): return True
    log("eval API down - restarting")
    subprocess.Popen(["bash","-c",f"cd '{WS}/evaluator' && EVAL_ADMIN_TOKEN=test-token-12345 PORT=8765 HOST=0.0.0.0 nohup Rscript app.R >/tmp/eval_api_restart.log 2>&1 &"])
    time.sleep(20); return api_ok()

def launch_resume():
    env = dict(os.environ, EVAL_API_URL="http://localhost:8765", RUN_INDEX="1", WIKI_VERSION="0531", THINKING_LEVEL=THINK_LABEL)
    subprocess.Popen(["openclaw","agent","--agent","main","--session-key",SK,"--model",MODEL,
                      "--thinking",THINK_FLAG,"--timeout","14400","--message",MSG,"--json"],
                     env=env, stdout=open(LOG.replace(".log","_resume.log"),"a"), stderr=subprocess.STDOUT)

log(f"=== armed === model={MODEL} flag={THINK_FLAG} label={THINK_LABEL} scored={scored()}/{TARGET} files={file_count()} status={session_status()}")
last_sc, last_files, stuck, rl_streak = scored(), file_count(), 0, 0
for cycle in range(1, MAX_CYCLES + 1):
    if scored() >= TARGET:
        log(f"COMPLETE - {scored()}/{TARGET} scored, {trials()} trials. stop."); break
    if not ensure_api():
        log("API still down - wait 120s"); time.sleep(120); continue
    log(f"cycle {cycle}: resuming (scored={scored()} trials={trials()} files={file_count()} status={session_status()})")
    launch_resume()
    time.sleep(120)
    waited = 0
    while is_working():
        if scored() >= TARGET: break
        time.sleep(60); waited += 60
        if waited > 1500: log("single run >25min - re-checking"); break
    new_sc, new_files = scored(), file_count()
    if new_sc > last_sc or new_files > last_files:
        stuck, rl_streak = 0, 0
        log(f"progress: scored={new_sc}/{TARGET} files={new_files}")
    elif rate_limited():
        rl_streak += 1
        backoff = min(180 * (2 ** min(rl_streak - 1, 2)), 600)   # 180, 360, 600, 600 ...
        log(f"RATE-LIMITED (streak={rl_streak}/{RL_LIMIT}) - backing off {backoff}s (quota recovering)")
        if rl_streak >= RL_LIMIT:
            log("rate-limit persisted too long - stopping; retry later."); break
        time.sleep(backoff)
    else:
        stuck += 1
        log(f"no progress, not rate-limited - stuck={stuck}/{STUCK_LIMIT}")
        if stuck >= STUCK_LIMIT:
            log(f"STUCK {STUCK_LIMIT}x - stopping (inspect {LOG})."); break
    last_sc, last_files = new_sc, new_files
log(f"=== ended === scored={scored()}/{TARGET} trials={trials()} files={file_count()}")
