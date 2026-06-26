---
name: make-goal
description: Turn a wish into a concise, runnable Claude Code /goal prompt. Infers the completion condition from the conversation, drafts it for approval, then writes a lean .goal/<slug>.md you run with `/goal @.goal/<slug>.md` (or paste into a fresh agent). Generated goals tell the executor to solve the problem with a team of subagents (a min–max team budget per iteration). Also explains what /goal is. Use for "make a goal", "formulate a goal prompt", "write a /goal condition", "turn this into a goal", "what is /goal".
argument-hint: [what you want to accomplish — optional; defaults to the conversation]
---

You are in **make-goal** mode. Turn a wish into a **concise, runnable goal prompt**
saved as `.goal/<slug>.md`, launched with `/goal @.goal/<slug>.md` or pasted into a
fresh agent. Output is *always* a lean goal file in the shape below — never a plan or
an essay.

If the user just asks **"what is `/goal`?"** (no goal to author), answer from
[references/goal-command.md](references/goal-command.md) and stop.

## What the file is

`/goal @file` inlines the **entire file** as the condition: the executor reads it as
its kickoff directive, and a small fast model (Haiku) **re-reads the whole thing every
turn** to judge completion — it **can't run tools**, it only sees what's surfaced in
the conversation. The condition is **hard-capped at 4,000 characters**, but that's a
ceiling, not a target: **write it lean** — a fresh agent should grasp it at a glance.

- **Concise by default.** Include only what makes the agent succeed and the goal
  checkable; drop everything else. A lean file is usually a few hundred chars.
- **Close every open thread.** An ambiguous stop condition is a loop that never ends
  or ends wrong. Drive ambiguity to zero before writing.

## Process — two phases (no interrogation)

**Phase 1 — Draft & confirm.** Don't write yet.
1. Read the conversation + `$ARGUMENTS`. Infer the goal and its `DONE WHEN` criteria.
2. For each criterion, give the **observable proof** — command + expected output the
   agent will surface (e.g. "`git status --porcelain` prints nothing"). If it can't be
   shown in conversation, it isn't a valid criterion — rewrite or drop it.
3. Mark any **soft/advisory** criterion (judged from what the agent *says*, e.g.
   "until confident") and warn if the goal is mostly soft — it'll stop early or never.
4. If the input's too thin to make criteria observable, say so and ask the user to
   fill the gaps — don't fabricate. Flag gaps in prose; no structured interview.
5. Present the **draft file** + a one-line audit (hard vs soft, assumptions, char
   count). **Wait** for approval.

**Phase 2 — Write.** After approval:
6. Save to `.goal/<slug>.md` (`<slug>` = task name, kebab-case, never a date — these
   are re-runnable). Confirm the path.
7. Keep the **whole file ≤4k** (it all becomes the condition); lean output clears this
   easily. Echo the paste-ready `/goal @.goal/<slug>.md`. Default to git-tracked.

## The goal file shape (lean)

```
# Goal: <one line — what, and why this framing>

## Run
You're the orchestrator of a team of subagents — team budget <min>–<max> per iteration. Decompose the work, delegate the pieces, then integrate and verify. Don't do it all in the main thread. Stop after <N> turns if not met.

## DONE WHEN
1. <end state> — <observable proof: command + expected output>
2. <end state> — <proof>
```

- **Core only:** `# Goal`, `## Run` (team framing + bound), `## DONE WHEN`. That's it
  for most goals.
- **Add a section only when it carries weight:** a hard constraint → a one-line
  `Guardrail:` under `DONE WHEN` (or a `## Guardrails` list if several); non-obvious
  paths/access → `## Environment`; must-read files → `## Pointers`. Omit empty
  sections — no placeholders.
- **Defaults:** team budget **1–3** per iteration — `min` is a floor (≥1 ⇒ the main
  thread orchestrates, it doesn't do the work itself), keep **max odd** for
  tie-breaking. Always include the bound.
- For a harness without `/goal`, prepend the portable preamble from
  references/goal-command.md (the 4k cap is a `/goal` limit, irrelevant there).

## Rules
1. **Concise, not cramped.** Cut everything inessential; keep every word the agent
   needs. Omit empty sections.
2. **Whole file ≤4k.** `/goal @file` inlines all of it. If it won't fit, the goal's
   too big — split it, or push detail into a pointed-to file.
3. **Every criterion observable**, proof baked in — the evaluator can't run tools.
4. **Zero open threads**; label soft criteria; warn if mostly soft.
5. **Always bound** the loop (`stop after N turns`).
6. **Team framing in every goal** — name the team + per-iteration budget; tell the
   agent to decompose/delegate/integrate/verify, not work solo. (Guidance to the
   executor, never a `DONE WHEN` criterion — the evaluator can't see *how* work was done.)
7. **Name by task, not date; tracked by default. Pointers over prose.**

## Two archetypes
- **Fixed iteration** — the bound is the finish line: "N rounds, then stop."
- **Conditional / convergence** — "until X holds," plus a bound as escape hatch.
- They combine: a convergence target + a hard bound.

## Worked example (lean)

```
# Goal: migrate src/auth to the v2 API

## Run
You're the orchestrator of a team of subagents — team budget 1–3 per iteration. Decompose the migration, delegate call sites to subagents, then integrate and verify. Don't do it all in the main thread. Stop after 25 turns if not met.

## DONE WHEN
1. `npm test test/auth` exits 0 (show output).
2. `grep -rn "authV1(" src/` prints nothing.
Guardrail: change nothing outside src/auth/.
```

See [references/goal-command.md](references/goal-command.md) for full `/goal`
semantics, the portable preamble, and what makes a good condition.
