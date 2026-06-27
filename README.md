# agent-brakes

Curated brake skills for AI coding agents — pause, align, reset context.

These are slash-command skills for [Claude Code](https://claude.com/claude-code) that restrain or redirect agent behavior along three axes: **eagerness** (slow it down), **alignment** (make it surface assumptions), and **context-rot** (reset state cleanly).

## Cheatsheet

A one-page visual guide — *When to reach for which brake* — maps the three axes (eagerness, alignment, context-rot) to specific brake skills and shows when to reach for each.

Refer to **[cheatsheet.pdf](cheatsheet.pdf)** to understand how these brakes work together.

## Install

```sh
git clone <this-repo> agent-brakes
cd agent-brakes
./install.sh
```

By default this symlinks each skill into `~/.claude/skills/`. Restart your Claude Code session and the `/<skill-name>` commands become available.

### Install options

| Flag | Effect |
| --- | --- |
| `--copy` | Copy skill directories instead of symlinking. Edits to the installed copy don't flow back to the repo. |
| `--project` | Install into `$(pwd)/.claude/skills` so the skills are scoped to a single project. |
| `--target=<dir>` | Install into an arbitrary directory. Overrides `--project`. |

If any target path already exists, install refuses to touch anything and tells you what's in the way.

## The skills

| Skill | One-liner |
| --- | --- |
| `/no-eager` | Respond in conversation only; read-only tools to ground the answer, no state changes. |
| `/clarify` | Pause for clarifying questions before any action. |
| `/align` | Restate scope, target, method, and stopping condition before tool calls. |
| `/breakdown` | Break down the questions or tasks in the prompt. |
| `/approval` | Pause and wait for explicit approval before any change. |
| `/formalize-plan` | Enter plan mode and produce a formal plan before implementing. |
| `/formalize-plan-delegated` | Like `/formalize-plan`, but the plan is written to be executed by a fresh subagent. |
| `/no-op` | Absorb the provided context without acting on it. |
| `/handoff` | Produce a self-contained handoff doc for a fresh agent or human. |
| `/latent-demand` | Surface the broader aspirations or deeper needs behind the prompt. |

## Uninstall

```sh
./uninstall.sh
```

Same flags as `install.sh` (`--project`, `--target=`).

`uninstall.sh` only removes symlinks that point back into this repo. If you installed with `--copy`, the directories are plain copies — uninstall will skip them and you'll need to remove them manually:

```sh
rm -rf ~/.claude/skills/{no-eager,clarify,align,breakdown,approval,formalize-plan,formalize-plan-delegated,no-op,handoff,latent-demand}
```

## Scope

This is Claude Code-targeted for now. Support for other agent harnesses may come later.
