# Findings — Does the wiki actually help the agent?

_What we learned from comparing benchmark runs with no wiki, the old wiki (0530),
and the new wiki (0531). Plain-language summary first; technical detail below._

---

## In plain language

**The big finding:** we gave the AI agents a study guide (the "wiki") to help them
write insurance models, then checked whether it helped. **It mostly didn't — and in one
case it actively made things worse.**

**Why:** the agents **copy the example code** in the guide; they barely use the written
explanations. So the guide only helps when its example is good, and it *hurts* when the
example looks fine but has a hidden weakness.

**The clearest proof** is one agent (gpt5.4):
- it read the guide,
- it saw the error message warning its model was broken,
- it even wrote out the correct fix in its own notes,
- and then it copied the guide's flawed example anyway — producing a broken model.

It knew the right answer and still followed the example. So the example is what drives
behavior, not understanding. (Another clue: reading *more* of the guide didn't help —
some agents that read almost all of it did great, others that read just as much did
terribly. The difference was always *which example they copied*, not how much they read.)

**The four ways models broke** (think of each example as a recipe):
1. The basic insurance model recipe was **missing a safety step** → it silently broke on
   hard data. *(This model type was later dropped, so it no longer matters.)*
2. The "grouped" recipe **forgot to put all the numbers on the same scale** → the model
   collapsed.
3. The "smooth-curve" recipe had a setting **hard-coded to one dataset** → it **crashed**
   on a different dataset. But a crash is *loud* — the agent sees it and fixes it. So this
   one mostly self-corrected.
4. The "boosted-trees" recipe told agents to **learn too slowly with a fixed budget** →
   the model never finished learning and quietly **underperformed**, only on the hard
   dataset. Nothing crashed, so nobody noticed. **This is the one real case where the
   guide made things worse.**

**The lesson:** when a bad recipe *crashes*, the agent fixes it; when it *fails quietly*,
the agent ships it. Quiet failure is the dangerous kind.

**What the guide update (new version) did — and missed:**
- For two recipes it fixed the **explanation text** but not the **example code**. Since
  agents copy code and skip text, **those fixes did nothing.** The boosted-trees recipe —
  the one that actually hurt — was left **completely unchanged**, so it still hurts.
- For two other recipes it *did* fix the code — but made it **more complicated**. The
  agents then copied it sloppily and the model broke anyway. **Making the example fancier
  backfired**, because the agents don't copy carefully.

**Bottom line:** a study guide helps an agent only through the **example it copies**, and
only when that example is **safe to copy onto a brand-new dataset**. Fixing the prose, or
adding cleverness the agent won't reproduce faithfully, does not help.

---

## Technical detail

### Setup
A **generalization benchmark**: the wiki was built from a reserved corpus; the six
datasets (`fremtpl2`, `ausprivauto`, `auto_insurance`, `bemtpl97`, `sgautonb`,
`swautoins`) are held out. Agents auto-build Tweedie models under three conditions:
**no-wiki**, **wiki0530** (old), **wiki0531** (new). All Gini values are grader-side
**test_gini (0–1)**.

**Clean scope** for three-way comparison = the 6 models present in all three arms:
opus47·claudecode, sonnet46·claudecode, gpt5.4·codex, gpt5.5·codex,
gemini3.1pro·antigravity, gemini35flash·antigravity.

### The mechanism: agents copy the example, skim the prose
- **Reading volume is uncorrelated with success.** Runs reading 49 distinct pages sit at
  both the top (+0.217 critical Gini) and bottom (−0.154) of the ranking.
- **The crowding-out case (gpt5.4):** read 49 pages, *saw* the "did not converge"
  warning, *named* both fixes (`maxit`, `mustart`) in its reasoning, and still **shipped
  the bare example call** → diverged (−0.069). Knowledge present, behavior driven by the
  example.
- The outcome is decided by ~4 tokens of code (`maxit`+`mustart` present → +0.258 on
  fremtpl2 GLM; absent → −0.258). Those tokens come from the example.

### The four failure modes (root cause traced to code / R logs)
| Mode | Model · dataset | Signature | Root cause | Failure type |
|---|---|---|---|---|
| M1 | GLM · fremtpl2/ausprivauto | Gini −0.258, ½ trials NA | bare `glm()`, no `maxit`/`mustart` → `NA/NaN/Inf` | **silent** |
| M2 | GrpLasso · auto_insurance | `n_active`→2, Gini 0.11 | unscaled numerics into `cv.HDtweedie` | **silent** |
| M3 | GAM · sgautonb | 0/N graded (crash) | hardcoded `k` > unique values (65 logs) | **loud** |
| M4 | TDboost · fremtpl2 | ~0.06 below baseline | `shrinkage=0.005` + fixed 3000 trees + CV-deviance early-stop → underfit | **silent** |

### A demo's value = correct × complete × data-appropriate; danger = silent vs loud
| Form | Behavior | Result |
|---|---|---|
| Correct but **incomplete** (missing a guard) | copy → inherit the gap | worse than no-demo *if silent* (M1, M2) |
| **Wrong** (has a bug) | copy the bug | crash/error — *not present in either wiki* |
| Correct but **simple/suboptimal** | copy | underfit; shows only on hard data (M4) |
| Correct but **complex/adaptive** | copy with *lower fidelity* | helps only if copied faithfully; agents simplify/skip it |

Cross-cutting: **silent vs loud** is the strongest predictor (same incomplete form fails
silently for GLM → shipped, but loudly for GAM → self-fixed); a fix in the **example
code** transfers, the same fix in **prose** does not; the example's authority **overrides**
the agent's own prior and the R warning.

### Classifying the two wiki versions (per method — neither is one "form")
| Method | example file | wiki0530 | wiki0531 | code changed? |
|---|---|---|---|---|
| GLM (M1) | smyth-jorgensen | incomplete (bare glm) | complete+adaptive (`maxit`/`mustart`/converged-check) | yes (but **GLM dropped in v5** → moot) |
| GrpLasso (M2) | qian-2016 | incomplete (hardcoded scale list) | complete+adaptive (scale all numerics, self-check) | yes |
| GAM (M3) | wood-2011 | hardcoded `k` (loud) | **UNCHANGED** (prose-only edit) | no |
| TDboost (M4) | yang-2016 | `shrinkage=0.005` recipe | **UNCHANGED** (page never touched) | no |

So the old→new change is a *natural experiment with a different transition per method*:
GLM and GrpLasso got their **code** upgraded; GAM and TDboost are **frozen controls**
(only prose changed).

### Three-arm results — and why they were predictable
| Mode | old→new code change | Result | Why |
|---|---|---|---|
| **M4 TDboost** | none (frozen) | **PERSISTS** (sonnet46 Δ0.063 z=5.0; gemini3.1pro Δ0.044) | example unchanged → behavior unchanged. **The one robust, significant harm.** |
| **M2 GrpLasso** | upgraded (more complex) | **fix didn't take** — collapses reappear (one agent ignored the new scaling; two scaled but still degraded) | complex example copied with lower fidelity |
| **M3 GAM** | none (prose only) | few crashes in scope | mode is *loud* → agents self-correct regardless of wiki |
| **M1 GLM** | upgraded | **untestable** — GLM dropped from v5 | fix never exercised |

**The punchline:** the update hardened the channel agents skim (prose) and the modes that
weren't hurting, and left the one mode the wiki actually *caused* (TDboost) untouched.

### Evidence standard (every claim graded on four layers)
Outcome · mechanism · significance · counterfactual.
- **Robust:** the TDboost harm (all four layers; z=5.0, recipe verified in 3 agents' code).
- **Robust but moot:** the GLM harm (GLM dropped from v5).
- **Retracted under the bar:** "wiki helps grouped-lasso" (not significant, Fisher p≈0.13;
  most no-wiki runs scale anyway) and "more reading → worse" (effect is *neutral*, CI
  spans zero — not harmful).

### Next step — a clean single-variable experiment
Take one method and feed agents different versions of its example — good, incomplete,
too-simple, too-complex, and a deliberately-buggy one — holding everything else fixed, and
measure: (1) how faithfully they copy, (2) the outcome, (3) whether they self-rescue from
warnings. Highest-value single edit: rewrite the **TDboost example** to learn properly and
adapt to the data — the only place the wiki still actively misleads.
