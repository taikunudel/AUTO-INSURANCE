#!/usr/bin/env python3
"""
Aggregate benchmark results across run-* folders.

Default: one completeness line per run (scored/24, where scored = rows in
results/summary.csv with a real non-NA mean_eval_gini).
--tidy : dump a tidy CSV (run,dataset,model,mean_eval_gini,mean_test_gini,success_rate)
         for every run to stdout, for pivoting/comparison.

Usage:
  python3 operator/collect-results.py [--tidy]
"""
import csv, glob, os, sys

WS = os.environ.get("WORKSPACE") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGET = 24  # 6 datasets x 4 models
V5_MODELS = {"tweedie_gam", "grplasso", "grpnet", "tdboost"}  # GLM dropped in v5


def rows_for(run_dir):
    path = os.path.join(run_dir, "results", "summary.csv")
    if not os.path.exists(path):
        return None
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def is_scored(row):
    g = (row.get("mean_eval_gini") or "").strip().strip('"')
    return g not in ("", "NA", "NaN")


def main():
    tidy = "--tidy" in sys.argv
    runs = sorted(glob.glob(os.path.join(WS, "run-*")))
    if not runs:
        print(f"no run-* folders under {WS}", file=sys.stderr)
        sys.exit(1)

    if tidy:
        w = csv.writer(sys.stdout)
        w.writerow(["run", "dataset", "model", "mean_eval_gini", "mean_test_gini", "success_rate"])
        for d in runs:
            rows = rows_for(d)
            if not rows:
                continue
            for r in rows:
                w.writerow([os.path.basename(d), r.get("dataset"), r.get("model"),
                            r.get("mean_eval_gini"), r.get("mean_test_gini"), r.get("success_rate")])
        return

    print(f"{'run':<70} {'scored':>9} status")
    for d in runs:
        rows = rows_for(d)
        name = os.path.basename(d)
        if rows is None:
            print(f"{name:<70} {'-':>9} no summary.csv yet")
            continue
        scored = sum(1 for r in rows if r.get("model") in V5_MODELS and is_scored(r))
        status = "COMPLETE" if scored >= TARGET else f"incomplete ({TARGET - scored} to go)"
        print(f"{name:<70} {scored:>6}/{TARGET} {status}")


if __name__ == "__main__":
    main()
