# auto-insurance — an LLM-agent generalization benchmark

**The question:** if you hand an AI coding agent a curated knowledge wiki, does it
actually do better work on data it has never seen?

**The setup:** an AI agent is dropped into this workspace and asked to autonomously
write R that fits four insurance pricing models (Tweedie GAM, grouped lasso, grouped
elastic net, boosted trees) across **six held-out insurance datasets**, scored by Gini
against a sealed eval API. The wiki (`knowledge-base/`) was built from a *reserved*
corpus — the benchmark datasets are deliberately absent from it, so any
dataset-specific fix has to be discovered by the agent itself. We ran the same agents
three ways: **no wiki**, with the **original wiki (0530)**, and with an **updated wiki
(0531)**.

> 🛠 **Want to run it?** Setup and launch instructions live in
> [`OPERATOR.md`](OPERATOR.md) (humans) and [`MASTER.md`](MASTER.md) (operator agents).
> ⚠️ *Benchmark agents must not read this file or `FINDINGS.md` — they reveal the
> held-out fixes.*

---

## What we found (the short version)

**The wiki mostly didn't help — and in one case it actively hurt.** The full analysis
is in [`FINDINGS.md`](FINDINGS.md); here is the story:

1. **Agents copy the wiki's example code; they barely act on its written
   explanations.** The clearest proof: one agent read 49 wiki pages, saw R's
   "did not converge" warning, wrote the correct fix in its own reasoning — and still
   shipped the wiki example's flawed call, producing a worse-than-random model. The
   example drives behavior; understanding doesn't.

2. **How much an agent read didn't predict anything.** Heavy readers landed at both
   the top and the bottom of the ranking. What mattered was whether the example they
   copied was safe to copy.

3. **Quiet failures are the dangerous ones.** When a flawed recipe *crashes*, the
   agent sees the error and fixes it. When it *silently underperforms* — like the
   boosted-trees recipe, which tells agents to learn too slowly with a fixed budget —
   the agent ships it and nobody notices. That recipe cost ~6 Gini points on the
   hardest dataset, and it is the one place the wiki made agents reliably worse than
   having no wiki at all.

4. **The wiki update (0531) fixed the wrong channel.** It improved the *prose*
   (pitfall warnings agents skim) and left the harmful boosted-trees *example*
   untouched — so the one real harm persisted. Where it did improve example code, it
   made the code more elaborate, and agents copied it sloppily, breaking it anyway.

**The lesson for anyone building knowledge bases for agents:** a wiki helps an agent
only through the example it copies, and only when that example is safe to copy
verbatim onto unseen data. Fixing explanations, or adding cleverness the agent won't
reproduce faithfully, does not transfer.

➡ **Full analysis** — failure modes with root causes, the hypothesis framework, the
three-arm comparison, and the evidence standard: [`FINDINGS.md`](FINDINGS.md)

---

## Repo map

| path | what |
|---|---|
| [`FINDINGS.md`](FINDINGS.md) | the analysis: what the wiki did and didn't do |
| [`OPERATOR.md`](OPERATOR.md) | how to set up and run the benchmark |
| `MASTER.md` · `RUNBOOK.md` · `roster.yaml` | operator-agent playbook, per-harness launch commands, model grid |
| `CLAUDE.md` · `AGENTS.md` · `GEMINI.md` | the benchmark agent's contract |
| `plan_v5.md` · `checklist_v5.md` | the task spec the agent implements |
| `knowledge-base/` | the wiki under test (snapshot 0531) |
| `evaluator/` | the sealed scoring API |
| `do_not_read/` | operator-only artifacts — off-limits to benchmark agents |
