#!/usr/bin/env python3
"""mech-audit.py — zero-token mechanical audit of benchmark run folders.

Checks every machine-verifiable item of checklist_v5.md and writes
operator/audits/<folder>-mech-audit.md plus a compact stdout grid.
Items needing human/LLM judgment are marked MANUAL.

Usage: python3 operator/mech-audit.py [run-folder ...]   (default: all run-*/)
"""
import csv, glob, hashlib, json, os, re, subprocess, sys

WS = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(WS)

def grep(pattern, paths, flags=re.I):
    rx = re.compile(pattern, flags)
    hits = []
    for p in paths:
        try:
            with open(p, errors="ignore") as f:
                for i, line in enumerate(f, 1):
                    if rx.search(line):
                        hits.append((p, i, line.strip()[:120]))
        except (IsADirectoryError, FileNotFoundError):
            pass
    return hits

def md5(p):
    h = hashlib.md5()
    with open(p, "rb") as f:
        for c in iter(lambda: f.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()

def audit(D):
    R = []          # (item, verdict, note)
    def add(item, ok, note=""):
        R.append((item, "PASS" if ok is True else ("FAIL" if ok is False else ok), note))

    base = os.path.basename(D.rstrip("/"))
    procs = sorted(glob.glob(f"{D}/procedures/*.R"))
    libs  = sorted(glob.glob(f"{D}/lib/*.R"))
    code  = procs + libs + sorted(glob.glob(f"{D}/agent/*")) + \
            [p for p in glob.glob(f"{D}/*.py")] + [p for p in glob.glob(f"{D}/*.R")]
    summ  = f"{D}/results/summary.csv"
    run_idx = (re.search(r"-run(\d+)-", base) or [None, None])[1]

    # Phase 0
    add("0.1 folder naming", bool(re.match(
        r"^run-(claudecode|codex|openclaw|gemini|antigravity)-(or-)?[a-z0-9.-]+-run\d+-wiki0-\d{8}-\d{6}$", base))
        and "_" not in base, base)
    add("0.7 no do_not_read refs", not grep(r"do_not_read", code +
        glob.glob(f"{D}/logs/session_snapshot*.jsonl")), "")
    others = [os.path.basename(x.rstrip('/')) for x in glob.glob("run-*/") if os.path.basename(x.rstrip('/')) != base]
    leak = [h for o in others for h in grep(re.escape(o), code)]
    add("0.6 no other-workspace refs in code", not leak, leak[0][2] if leak else "")
    add("0.8 initial_prompt.md", os.path.isfile(f"{D}/initial_prompt.md"))

    # Phase 2C/4 pitfalls (code-level)
    p01 = [p for p in procs if "tweedie_gam" in p or "01" in os.path.basename(p)]
    add("2C.1 GAM Tweedie p=1.7 spelling", bool(grep(r"tw\s*\(\s*theta\s*=\s*1\.7|Tweedie\s*\(\s*p\s*=\s*1\.7|family\s*=\s*tw\(|link\s*=\s*power\(0\)|link\.power\s*=\s*0", p01)) if p01 else "NA")
    add("2C.2 GAM REML", bool(grep(r'method\s*=\s*"f?REML"', p01)) if p01 else "NA")
    add("2C.5 lambda.min predict", bool(grep(r"lambda\.min", procs)) if procs else "NA")
    add("2C.6 TDboost best_iter via cv", bool(grep(r'TDboost\.perf|method\s*=\s*"cv"|best_iter|best\.iter', procs)) if procs else "NA")
    add("2C.4 no-intercept design", bool(grep(r"~\s*\.?\s*-\s*1|intercept\s*=\s*FALSE", procs + libs)) if procs else "NA")
    add("4.2 p=1.7 in all 4 procedures",
        all(grep(r"1\.7", [p]) for p in procs) if len(procs) >= 4 else "MANUAL", f"{len(procs)} procedure files")

    # Phase 5
    add("5.1 --trial arg", all(grep(r"--trial|commandArgs", [p]) for p in procs) if procs else "NA")
    add("5.2 seed formula", bool(grep(r"set\.seed\s*\(\s*1000\s*\*\s*\w*RUN_INDEX\w*\s*\+", procs)) or
        bool(grep(r"1000\s*\*\s*as\.(integer|numeric)\(.*RUN_INDEX", procs)), f"RUN_INDEX(folder)={run_idx}")
    add("5.3 EVAL_API_URL_RESOLVED", bool(grep(r"EVAL_API_URL_RESOLVED", procs + code)) if procs else "NA")
    add("5.12 procedures never POST /score", not grep(r"/score", procs), "")

    # Phase 8/9
    add("8.9 Bearer test-token-12345", bool(grep(r"Bearer\s+test-token-12345|EVAL_ADMIN_TOKEN", code)))
    snap = f"{D}/logs/session_snapshot.jsonl"
    add("9.1 snapshot real file", (os.path.isfile(snap) and not os.path.islink(snap)) if os.path.exists(snap) else "NA",
        f"{os.path.getsize(snap)} bytes" if os.path.exists(snap) else "absent")

    # Phase 10/12 results integrity
    if os.path.isfile(summ):
        with open(summ) as f:
            rows = list(csv.DictReader(f))
        hdr = list(rows[0].keys()) if rows else []
        add("10.4 exact columns", hdr == ["dataset","model","n_completed","mean_eval_gini",
            "se_eval_gini","mean_test_gini","se_test_gini","success_rate"], ",".join(hdr)[:80])
        add("10.9 success_rate X/10", all(re.match(r'^"?\d+/10"?$', r.get("success_rate","")) for r in rows))
        add("12.4 24 summary rows", len(rows) == 24, str(len(rows)))
        scored = sum(1 for r in rows if (r.get("mean_eval_gini") or "").strip().lower() not in ("", "na", "nan"))
        add("scored 24/24", scored == 24, f"{scored}/24")
        def fnum(s):
            try: return float((s or "").strip().strip('"'))
            except ValueError: return None
        gv = [(r["dataset"], fnum(r.get("mean_eval_gini"))) for r in rows]
        gv = [(d, g) for d, g in gv if g is not None]
        add("7.1 gini in [-1,1]", all(-1 <= g <= 1 for _, g in gv))
        add("flag eval_gini>0.5", "WARN" if any(g > 0.5 for _, g in gv) else True,
            ",".join(sorted({d for d, g in gv if g > 0.5})))
        n_claim = sum(int(r["n_completed"]) for r in rows if (r.get("n_completed") or "").isdigit())
        n_disk = len(glob.glob(f"{D}/results/**/trial_*.csv", recursive=True))
        add("12.2 trial CSVs vs n_completed", (n_disk >= n_claim * 0.9) if n_claim else "NA",
            f"disk={n_disk} claimed={n_claim}")
        # copy detection
        h = md5(summ)
        dup = [o for o in glob.glob("run-*/results/summary.csv")
               if os.path.dirname(os.path.dirname(o)) != D.rstrip("/") and md5(o) == h]
        add("INTEGRITY summary unique", not dup, dup[0] if dup else "")
    else:
        add("12.4 summary exists", False, "no results/summary.csv")

    # seeds actually used (if trial CSVs record them)
    if run_idx:
        sd = grep(rf"\b{1000*int(run_idx)+1}\b", procs + glob.glob(f"{D}/logs/r_subprocess/*round*1*.log")[:5])
        add("5.2 seed base observed", bool(sd) or "MANUAL", f"expect {1000*int(run_idx)}+trial")

    add("13.x behavior items", "MANUAL", "transcript judgment — not mechanizable")
    return R

def main():
    targets = sys.argv[1:] or sorted(glob.glob("run-*/"))
    os.makedirs("operator/audits", exist_ok=True)
    grid = {}
    for D in targets:
        D = D.rstrip("/")
        if not os.path.isdir(D):
            continue
        res = audit(D)
        out = f"operator/audits/{os.path.basename(D)}-mech-audit.md"
        with open(out, "w") as f:
            f.write(f"# Mechanical audit — {os.path.basename(D)}\n\n"
                    "Deterministic checks only (zero-token). MANUAL = needs human/LLM judgment.\n\n"
                    "| item | verdict | note |\n|---|---|---|\n")
            for item, v, note in res:
                f.write(f"| {item} | {v} | {note} |\n")
        p = sum(1 for _, v, _ in res if v == "PASS")
        fl = [(i, n) for i, v, n in res if v == "FAIL"]
        w = [i for i, v, _ in res if v == "WARN"]
        grid[os.path.basename(D)] = (p, fl, w)
    name_w = max(len(k) for k in grid) if grid else 10
    for k, (p, fl, w) in sorted(grid.items()):
        flags = "; ".join(f"{i}({n[:40]})" if n else i for i, n in fl) or "-"
        warns = ",".join(w) or "-"
        print(f"{k:<{name_w}}  PASS={p:<3} FAIL={len(fl):<2} [{flags}] WARN[{warns}]")

if __name__ == "__main__":
    main()
