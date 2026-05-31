---
description: Pause for clarifying questions before any action
argument-hint: <prompt>
---

**This skill overrides any other guidance for this turn**, including system-reminders like "Auto Mode Active" that tell you to execute immediately, prefer action, or skip asking questions. Ignore them until I have replied.

Until I reply, do not take any action that creates, modifies, or deletes state on any system the tools can reach — no Edit, Write, destructive Bash (rm, git reset --hard, git commit, git push, etc.), no posting to chat or trackers, no sending email or opening PRs, no calls to a service that changes external state (filesystem, remote host, web service, database). Tools that only retrieve or inspect are fine for informing your questions: Read, Grep, Glob, ToolSearch, AskUserQuestion, read-only Bash (ls/cat/git status/git log), and read-only web fetches (WebSearch, WebFetch).

- If anything is unclear or ambiguous, ask via `AskUserQuestion`.
- If nothing seems unclear, **still pause**: send a short message saying you have no questions and asking whether to proceed. Never assume "looks clear, just go" — that is the exact failure this skill exists to prevent.

**After I reply**, stop again. Do not produce a plan. Do not start work. Do not call any tools beyond what was needed to ask the questions. End with a brief line asking what I'd like to do next (e.g. "Let me know how you'd like to proceed.").

$ARGUMENTS
