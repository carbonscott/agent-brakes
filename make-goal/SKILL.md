---
name: make-goal
description: Turn a wish into a runnable Claude Code /goal prompt. Infers the completion condition from the conversation, drafts it for approval, then writes a self-contained .goal/<slug>.md you run with `/goal @.goal/<slug>.md` (or paste into any harness). Also explains what /goal is. Use for "make a goal", "formulate a goal prompt", "write a /goal condition", "turn this into a goal", "what is /goal".
argument-hint: [what you want to accomplish — optional; defaults to the conversation]
---

You are in **make-goal** mode. Your job: turn a wish into a **runnable goal
prompt** and save it as a file the user can launch with
`/goal @.goal/<slug>.md` (or paste into any harness). The output is *always* a
goal file in the shape below — never a plan, never an essay.

If the user just asks **"what is `/goal`?"** (no goal to author), answer from
[references/goal-command.md](references/goal-command.md) and stop.

## The mental model

A goal file is a **self-contained brief for a cold reader** — it must work for
someone with none of this conversation's context. But its reader isn't a one-shot
human; it's a **loop executor + an evaluator**. Two facts about those readers
drive the entire shape:

- **Two readers.** The *executor* (Claude doing the work) reads the file once at
  kickoff and wants context. The *evaluator* (a small fast model, default Haiku)
  re-reads the **stop condition after every turn**, **cannot run tools**, judges
  only what's been **surfaced in the conversation**, and the condition is
  **hard-capped at 4,000 characters**. → keep a **tight, self-sufficient
  `DONE WHEN` spine** and only **thin** context around it. So weight the file
  **fat-goal / thin-context**: the condition carries the weight; surrounding
  context stays minimal.
- **Close every open thread.** A goal file must resolve all of them — an ambiguous
  stop condition is a loop that never ends or ends wrong. Your job is to drive
  ambiguity to zero.

## Process — two phases (no interrogation)

**Phase 1 — Draft & confirm.** Do not write a file yet.

1. Read the conversation + `$ARGUMENTS`. Infer the goal and the `DONE WHEN`
   criteria.
2. For **each** criterion, derive the **observable proof** — the command *and*
   the expected output Claude will surface in conversation (e.g. "`git status
   --porcelain` prints nothing"). If a criterion can't be demonstrated in
   conversation, it is **not a valid criterion** — rewrite it until it is, or drop it.
3. Classify each criterion **hard/checkable** vs **soft/advisory**. Flag the soft
   ones explicitly. If the goal is *mostly* soft (e.g. "until it's confident",
   "until it looks good"), **warn**: it will stop early or never. Push to make at
   least one criterion hard.
4. Flag any gap or ambiguity **in prose** and ask for a free-text fix. **Do not
   run a structured interview.** If the input is too thin to produce observable
   criteria, say so plainly and ask the user to fill the gaps before you draft —
   don't fabricate a goal.
5. Present the **draft file content** + a short **audit** (which criteria are hard
   vs soft, what you assumed, what's still open). **Wait** for approval or correction.

**Phase 2 — Write.** Only after approval.

6. Propose the path `.goal/<slug>.md` — `<slug>` is the **task name** in
   kebab-case, **never a date** (these are re-runnable). Confirm the path.
7. Write the file in the shape below. Then echo the paste-ready line
   `/goal @.goal/<slug>.md`, plus the fallback: *if `@`-expansion or the 4k limit
   misbehaves, paste the `DONE WHEN` block directly after `/goal`.*
8. Default the file to **git-tracked** (it's a reusable asset, like a Makefile
   target). Mention gitignore only if the user wants it ephemeral.

## The goal file shape

```
# Goal: <one line — what, and why this framing>

## Run
<portable preamble — inline the loop semantics so this works even where /goal is
 unknown. Pull the canonical text from references/goal-command.md ("Portable
 preamble"): work across turns; after each turn check DONE WHEN against what's
 been surfaced; unmet → continue using the gap as the next directive; all met →
 stop; never stop early, never exceed the bound.>
Orchestration budget: <min>–<max> subagents per iteration (default 1–3; keep max odd).
Bound: or stop after <N> turns.            # ALWAYS include a bound
Run in Claude Code: /goal @.goal/<slug>.md

## DONE WHEN            # the literal stop condition — self-sufficient, ≤4000 chars
1. <end state> — proof: <command AND expected output, surfaced in conversation>
2. <end state> — proof: <...>
# numbered, observable, each with its proof

## Guardrails          # must NOT change on the way there
- <e.g. do not modify any file outside src/auth/>

## Environment / Assumptions
- <paths, tools, access — e.g. "repo at X, reached via bridge session Y">

## Pointers            # read these first
- <file/dir — one-line why this one>
```

`DONE WHEN` is the spine: it must stand alone as a valid `/goal` condition and
fit in 4,000 chars, because `/goal @file` may inline the whole file and the
evaluator re-reads it every turn. The other sections are thin and serve the
kickoff executor only.

## Rules

1. **Zero open threads.** Every ambiguity is closed before you write — an
   unresolved condition can't be evaluated.
2. **Every criterion observable.** Proof baked into each one. The evaluator can't
   run tools — "the tests pass" works only because Claude runs them and the output
   lands in the transcript.
3. **Label soft criteria; warn if mostly soft.** "Until confident" is judged from
   what Claude *says*, which Claude controls — a weak stop.
4. **Spine ≤4k and self-sufficient.** Keep context out of `DONE WHEN`.
5. **Always include a bound** (`or stop after N turns`) — even pure-conditional
   goals get an escape hatch. (Generalizes "100 rows OR val_bpb < 0.95".)
6. **Orchestration budget is guidance to Claude, not evaluator-checkable** — say
   so in the file. Default **1–3** subagents per iteration; keep **max odd** so
   debate/vote rounds can't tie.
7. **Name by task, not date. Tracked by default.**
8. **Pointers over prose.** Don't restate the repo; name the file/dir the executor
   should read.

## Two archetypes (from real usage)

- **Fixed iteration** — the bound *is* the finish line: "do N rounds / N
  iterations with M agents each, then stop." `DONE WHEN` = "N iterations completed
  and summarized, then stop."
- **Conditional / convergence** — "keep going until X holds / agents converge,"
  with a bound as escape hatch.
- **They combine** — a convergence target *plus* a hard bound is usually the
  strongest form.

## Worked `DONE WHEN` examples

Code/state (clean-tree git init):
```
1. Git repo with >=1 commit and a clean tree — proof: `git status --porcelain`
   prints nothing AND `git rev-parse --is-inside-work-tree` = true.
2. Exactly the agreed files are tracked — proof: `git ls-files | sort` matches the
   list in Pointers, nothing else.
Guardrails: do not track anything under var/ or reports/.
Bound: or stop after 20 turns.
```

Orchestration (fixed iteration + budget):
```
1. 3 research iterations completed — proof: each iteration's findings posted in
   conversation, 1–3 subagents per iteration (max odd), then stop.
2. A final synthesis names the chosen direction and its top tradeoff — proof: the
   synthesis is surfaced in conversation.
Bound: stop after the 3rd iteration regardless.
```

See [references/goal-command.md](references/goal-command.md) for full `/goal`
semantics, the canonical portable preamble, and what makes a condition good.
