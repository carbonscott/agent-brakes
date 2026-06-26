# Claude Code `/goal` — reference

> Companion reference for the **make-goal** skill. It documents the **native
> Claude Code `/goal` command** and provides the **portable preamble** that
> `make-goal` inlines into generated `.goal/*.md` files. It does not implement
> anything. Use it to answer "what is `/goal`?" and to write good conditions.

## What it is

`/goal` sets a **session-scoped completion condition** and keeps Claude working
across turns until that condition is met. After each turn, a small fast model
(Haiku by default) reads the conversation and judges whether the condition
holds. If not, a new turn starts **automatically** — no re-prompting — using the
evaluator's reason as guidance. When the condition is met, the goal clears and an
achievement entry (duration, turn count, token spend) is logged to the
transcript.

In one line: *"keep at this until X is true, then stop."*

Good for substantial work with a verifiable end state — migrating call sites
until everything compiles, implementing a design doc until all acceptance
criteria hold, splitting a file until each module is under a size budget, draining
a labeled issue backlog.

## Syntax

| Command | Effect |
|---|---|
| `/goal <condition>` | Set the goal |
| `/goal @.goal/<slug>.md` | Set the goal from a file (the file's text becomes the condition) |
| `/goal` | Show status: condition, elapsed time, turns evaluated, token spend, evaluator's last reason |
| `/goal clear` | Cancel it (aliases: `stop`, `off`, `reset`, `none`, `cancel`) |
| `Ctrl+C` | Interrupt a running goal before the condition is met |
| `claude -p "/goal <condition>"` | Non-interactive: runs to completion in one invocation |

Max **4,000 characters** per condition. Setting a goal starts a turn immediately,
with the condition itself as the directive. `/goal` survives `--resume` /
`--continue` (the goal is restored), but the timer, turn count, and token baseline
reset. `/clear` removes any active goal.

## Writing good conditions

**The key constraint:** the evaluator only reads what Claude *surfaces in the
conversation*. It does **not** run tools or commands itself. So the condition
must be something Claude's own output can demonstrate.

A good condition has:

1. **One measurable end state** — a test result, build exit code, file count, an
   empty queue. Not "the code is better."
2. **A stated proof** — how Claude should show it: `npm test exits 0`,
   `git status is clean`, `src/ has exactly 5 .py files`.
3. **Guardrails** — anything that must not change along the way
   (e.g. "without modifying any file outside `src/auth/`").
4. **A bound** — `or stop after N turns` to guarantee termination.

**Good:**
- `all tests in test/auth pass and the lint step exits 0, without modifying any file outside src/auth/`
- `src/ contains exactly 5 .py files`
- `CHANGELOG.md has an entry for every PR merged this week, or stop after 15 turns`

**Bad:**
- `make the auth code cleaner` — not observable, no end state
- conditions that require running commands the evaluator can't see

Tip: test the condition with a single normal prompt first — confirm Claude can
*demonstrate* it in conversation — before wrapping it in `/goal`.

## `/goal` vs `/loop` vs stop-hooks vs auto mode

| Approach | Next turn starts when | Stops when | Use case |
|---|---|---|---|
| `/goal` | Previous turn finishes | Condition met | Work with a clear, verifiable finish line |
| `/loop` | A time interval elapses | You stop it, or Claude decides done | Repeating checks on a schedule |
| Stop hook | Previous turn finishes | A custom script/prompt decides | Deterministic or complex checks |
| Auto mode | (within a turn) | Tool-by-tool approval removed | Drop per-tool prompts |

- **Auto mode** removes per-*tool* approval prompts; `/goal` removes per-*turn*
  prompts. Use both together for fully hands-off runs.

## Requirements & limits

- Claude Code **v2.1.139+**.
- Workspace trust dialog must be accepted (hooks require it).
- Unavailable if `disableAllHooks` is set in any settings scope, or if
  `allowManagedHooksOnly` is set in managed settings.
- Mechanism: `/goal` wraps a session-scoped, prompt-based **Stop hook**. The
  evaluator runs on your configured provider, does not call tools, and its tokens
  bill to the small fast model (typically negligible).

## Portable preamble

Not every harness has `/goal`. When a generated `.goal/*.md` file may be run
somewhere that doesn't know the command, `make-goal` inlines this text into the
file's `## Run` section so the loop semantics are self-contained. Verbatim
snippet to adapt:

```
Keep working across turns toward the condition below. After each turn, re-read
DONE WHEN and check it against what you have surfaced in this conversation
(you cannot rely on tools the reader can't see). If every item is not yet
demonstrably met, continue — treat the unmet item as your directive for the next
turn. When all items are met, stop. Do not stop early on partial progress, and do
not exceed the bound. (In Claude Code, `/goal` automates exactly this loop.)
```

## Source

Official docs: https://code.claude.com/docs/en/goal.md
