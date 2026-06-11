# auto-insurance — an LLM-agent generalization benchmark

**The question:** if you hand an AI coding agent a curated knowledge wiki, does it
actually do better work on data it has never seen?

**The setup:** an AI agent is dropped into a workspace and asked to autonomously write
R that fits four insurance pricing models (Tweedie GAM, grouped lasso, grouped elastic
net, boosted trees) across **six held-out insurance datasets**, scored by Gini against
a sealed eval API. The wiki was built from a *reserved* corpus — the benchmark datasets
are deliberately absent from it, so any dataset-specific fix has to be discovered by
the agent itself. We ran the same agents three ways: **no wiki**, with the **original
wiki (0530)**, and with an **updated wiki (0531)**.

> 🛠 **Want to run it?** [`OPERATOR.md`](OPERATOR.md) (humans) and [`MASTER.md`](MASTER.md)
> (operator agents). ⚠️ *Benchmark agents must not read this file or
> [`FINDINGS.md`](FINDINGS.md) — they reveal the held-out fixes. (They can't anyway:
> agents run in generated workspaces that physically don't contain these files — see
> "How the experiment is isolated" below.)*

---

## The one-sentence finding

> An agent handed a wiki does not *learn* from it — it **copies the example code and
> skims the explanations**. So a wiki helps only where its runnable example is safe to
> copy onto unseen data, and it harms wherever the example looks correct but hides a
> silent flaw — which is exactly the failure the wiki's own update left untouched.

---

## Key results, as questions and answers

### Does reading more of the wiki help?
**No — reading volume predicts nothing.** Heavy readers landed at both the top and the
bottom; one of the best runs read only 10 of ~50 pages.

```
score on the two decisive cells (each ● = one wiki run)

 best  +0.22 |  ● opus47-r2 (10pg)        ● gpt5.5 (49pg)  ● flash-r1 (48pg)
       +0.10 |                            ● ocl-gpt5.5 (49pg)
        0.00 |  ● sonnet46-r2 (11pg)
       -0.07 |                            ● gpt5.4 (49pg)
       -0.15 |                            ● gpt5.3 (49pg)
 worst -0.20 |  ● g3.1pro (6) ● sonnet46-r1 (14)   ● flash-r2 (36pg)
             +----------------------------------------------------------
                LIGHT readers (3–14 pages)   HEAVY readers (36–49 pages)

      → both groups span top-to-bottom. Reading ≠ outcome.
```

### How is the agent *supposed* to use the wiki?
The workspace contract prescribes a four-step loop — orient, target, read, check —
ending in code that cites its sources:

```
   ┌──────────────────────────────────────────────────────────────┐
   │  workspace root: CLAUDE.md (auto-loaded contract)            │
   │  "You MUST consult the wiki before writing modeling code.    │
   │   Prefer examples/*.R — copy verbatim, then modify.          │
   │   Cite every decision as [[PageName]]. Skipping = failure."  │
   └───────────────────────────────┬──────────────────────────────┘
                                   ▼
   │  STEP 1 — ORIENT   index.md (catalog) · overview.md          │
   │                    (synthesis) · the wiki's own CLAUDE.md    │
                                   ▼
   │  STEP 2 — TARGET   grep -rli <every task term> wiki/         │
                                   ▼
   ┌──────────────────────────────────────────────────────────────┐
   │  STEP 3 — READ every match, all three page types             │
   │   concepts/<Method>.md      sources/<paper>.md               │
   │   · when to use, hyperparams· canonical API from the paper   │
   │   · COMMON PITFALLS         · quirks + FAILURE MODES         │
   │              └──────────┬──────────┘                         │
   │                         ▼                                    │
   │             examples/<method>.R                              │
   │             · verified runnable demo ← the active ingredient │
   └───────────────────────────────┬──────────────────────────────┘
                                   ▼
   │  STEP 4 — before each package call, re-read that page's      │
   │           Argument Quirks + Failure Modes + Code Example     │
                                   ▼
   ┌──────────────────────────────────────────────────────────────┐
   │  ACT — copy the example verbatim → adapt to this data →      │
   │        cite [[Pages]] in comments → log reads to trajectory  │
   └──────────────┬──────────────────────────────┬────────────────┘
                  ▼                              ▼
     run R → error? debug from the      wiki had nothing? log it in
     message + Failure Modes, loop      gaps.md, proceed citing
     until OK                           "no wiki support"
```

### …and how do they actually use it?
**They execute the reading steps, but only the example shapes the code:**

```
   DESIGNED:  orient → grep → read concepts+sources+examples → check quirks → write
   OBSERVED:  skim index ─────────────────────► copy examples/<method>.R → ship
                          (concepts read but not applied; warnings seen but overridden)
```

The cleanest proof: one agent read 49 pages, *saw* R's warning that its model hadn't
converged, *wrote the correct fix in its own reasoning* — and still shipped the
example's flawed call. Two other agents copied the same example so faithfully their
failures were **byte-identical to 13 decimals**. Reading produces *citations*; the
example alone produces the *code* — which is why a flaw in `examples/` propagates even
to agents that read everything, and why fixes placed in explanation prose never landed.

### How much code decides success?
**About four tokens.** Two small settings in one model call separate success from
worse-than-random — and having the wiki made agents *less* likely to write them
(27% vs 50% without the wiki), because the clean-looking example suppressed their own
debugging instinct.

```
did the run add the 2-line fix?    →    outcome on the hardest dataset

  YES  (8 runs)   ok ███████ 7      borderline █ 1      failed  0
  NO  (16 runs)   ok █ 1            borderline ██ 2     failed █████████████ 13

how often agents wrote the fix
  no wiki    ██████████  50%   (5 of 10 runs)
  with wiki  █████▌      27%   (4 of 15 runs)   ← the wiki made it LESS likely
```

### Which failures get fixed, and which get shipped?
**Loud failures get fixed; quiet ones get shipped.** Every crash was debugged and
repaired by the agent. Every silent underperformance was submitted unnoticed. The
dangerous wiki content is not wrong code that crashes — it's plausible code that
quietly scores low.

```
                 the copied example has a flaw
                            │
              ┌─────────────┴──────────────┐
        fails LOUD                    fails QUIET
     (crash / error msg)         (runs fine, scores low)
              │                            │
     agent sees the error           nothing to notice
     debugs, repairs it             agent ships it as-is
              │                            │
        ✔ recovers                  ✘ bad model submitted
```

### The four ways runs actually failed

| # | what happened | root cause (verified in code/logs) | loud or quiet? |
|---|---|---|---|
| 1 | basic model silently diverged | example omitted two safety settings | quiet |
| 2 | grouped model collapsed to ~useless | numeric columns not scaled | quiet |
| 3 | smooth-curve model crashed | copied setting didn't suit the new data | **loud → self-fixed** |
| 4 | boosted trees quietly lost ~6 pts on the hard dataset | example trains too slowly with a fixed budget | quiet — **the one failure the wiki itself caused** |

### Did the wiki ever help?
**Yes — its biggest effects are rescues**: runs *without* the wiki suffered collapses
and crashes that wiki-equipped runs avoided. Honest caveat: the helps rest on a couple
of events and fail a strict statistical test (most no-wiki agents avoid those traps on
their own); the two harms *pass* it.

### Did the updated wiki (0531) fix the problems?
**It fixed the wrong channel.** The update added warning text to explanation pages
(which agents skim) and left the harmful boosted-trees **example** untouched — so the
one real harm persists, unchanged:

```
boosted trees on the hardest dataset (same agent across all 3 arms)

  no wiki    ████████████████▌  0.330   ← what the agent does on its own
  old wiki   █████████████▏     0.263   ← example drags it down ~6.6 pts
  new wiki   █████████████▎     0.267   ← unchanged: the example was never edited

why: the example's settings make the model learn ~4× less before stopping
  no wiki   amount learned ████████████████████  8.8  → 0.330
  wiki      amount learned █████                 2.0  → 0.26x
```

And where the update *did* improve an example, it made the code more complex — and
agents copied it carelessly. Collapses returned to the no-wiki rate:

```
runs where the grouped model collapsed

  no wiki    ██░░░░░░░░░   2 of 11  (18%)
  old wiki   ░░░░░░░░░░░   0 of 18   (0%)
  new wiki   ██░░░░░░░░░   3 of 17  (18%)  ← WITH the explicit fix in the example
```

### Why is the wiki built to fail this way?
It's a good literature summary aimed at the wrong consumer. **~37 of its 45 files are
explanation; agents act on the 8 examples.** Its feedback log only learns from loud
errors (the quiet boosted-trees harm never appears in it). And its paper-summarizing
template records each paper's "recommended setting" as a single number — which agents
copy as if universal, inheriting the paper's blind spots.

```
where the wiki's content sits          what drives agent behavior
  explanations ████████████████████ 37 files     (read, then ignored)
  examples     ████ 8 files                      ←  copied into the final code
```

---

## The theory this leaves us with

An example's **value = correct × complete × suits-your-data**. Its **danger = whether
failure is silent.** Four example types, three observed here:

| example type | what agents do | result |
|---|---|---|
| correct but **incomplete** | copy the gap | silent failure — *worse than no example* (it crowds out the agent's own debugging) |
| **wrong** (buggy) | copy the bug | crash → agent self-fixes *(not present in either wiki; must be injected to test)* |
| correct but **too conservative** | copy | quiet underperformance, visible only on hard data |
| correct and **adaptive** | copy *sloppily* | best only if copied faithfully — complexity often doesn't survive copying |

**Next experiment (designed, not yet run):** one model type, six versions of its
example (none / ideal / incomplete / buggy / too-simple / adaptive), ≥3 runs each;
measure copy fidelity, score, reaction to warnings, citations. The single most
valuable edit regardless: rewrite the boosted-trees example — the one place the wiki
still actively misleads.

---

## How the experiment is isolated (and how to replicate it)

Every experimental arm lives in this repo under `conditions/`, and **agents never run
inside the repo**. The operator materializes a *clean-room workspace* containing only
one arm's contracts + wiki + the task spec:

```
repo (operator territory)                 agent workspaces (generated)
├── conditions/wiki-0531/    ──┐
├── conditions/wiki-0530/    ──┼── make-workspace.sh ──►  ~/bench/ws-<arm>/
├── conditions/no-wiki/      ──┘                          ├── CLAUDE.md (that arm's contract)
├── plan_v5.md  evaluator/  operator/                     ├── knowledge-base/ (that arm's wiki, if any)
├── FINDINGS.md  do_not_read/  paper/                     ├── plan_v5.md, checklist_v5.md
│   (analysis — never copied to workspaces)               └── CONDITION.txt (arm + repo SHA stamp)
```

Knowledge separation is **physical, not instructional**: an agent cannot read a wiki
that does not exist in its world. `CONDITION.txt` records which arm + repo commit each
run actually used — provenance is a recorded fact, not a folder-name label.
`operator/check-structure.sh <ws>` verifies a workspace matches its stamp before launch.

Replicate on any machine:
```bash
git clone https://github.com/taikunudel/AUTO-INSURANCE.git && cd AUTO-INSURANCE
./setup.sh && ./setup.sh --start-api && ./smoke.sh        # env + eval API + end-to-end check
operator/make-workspace.sh wiki-0530                       # any arm: wiki-0531 / wiki-0530 / no-wiki
operator/check-structure.sh ~/bench/ws-wiki-0530           # must print PASS
# then launch per RUNBOOK.md with cwd = the workspace
```

---

## Honesty section — what we got wrong along the way

Kept on record deliberately; every claim in this README survived a 4-layer bar
(outcome · mechanism · significance · counterfactual):

1. "More reading → worse" — **retracted** (the true effect is zero, not negative).
2. "The wiki clearly helped the grouped model" — **retracted** (fails significance;
   most no-wiki agents scale on their own).
3. Our first explanation of the boosted-trees harm ("hit the tree ceiling") was an
   artifact from the wrong dataset; the verified cause is slow learning stopped early.
4. One claimed crash cause appears in code but in **zero** captured logs — downgraded
   from "verified" to "inferred."
5. Early comparisons silently dropped cells where no-wiki produced nothing at all —
   hiding that no-wiki had ~2× the total failures.

**Known limits:** most per-arm failure counts are 1–3 events (only the two harms reach
statistical significance); the boosted-trees learning-rate number rests on one
surviving log (the recipe itself is verified in three agents' code); the new wiki's
suspected "scale everything" backfire is a single run; repeat runs and the six-version
example experiment have not been run yet.

---

## Repo map

| path | what |
|---|---|
| [`FINDINGS.md`](FINDINGS.md) | the full technical analysis |
| [`OPERATOR.md`](OPERATOR.md) | how to set up and run the benchmark |
| `conditions/` | the experimental arms: `wiki-0531/`, `wiki-0530/`, `no-wiki/` (each = agent contracts + wiki payload) |
| `operator/make-workspace.sh` · `check-structure.sh` | materialize a clean-room agent workspace; verify it matches its stamp |
| `MASTER.md` · `RUNBOOK.md` · `roster.yaml` | operator-agent playbook, per-harness launch commands, model grid |
| `CLAUDE.md` · `AGENTS.md` · `GEMINI.md` | operator orientation (benchmark contracts live in `conditions/<arm>/`) |
| `plan_v5.md` · `checklist_v5.md` | the task spec (invariant across all arms) |
| `evaluator/` | the sealed scoring API |
| `do_not_read/` | operator-only analysis vault — never materialized into workspaces |
