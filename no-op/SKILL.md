---
description: No operation — absorb the provided context or read the referenced material, then stop. Use when the user wants the agent to take in information without acting on it. Triggers on "/no-op", "just read this", "just absorb this", "no action", "don't do anything yet", or any prompt where the user is loading context for a future request.
argument-hint: (optional — context, file path, or material to absorb)
---

**This skill overrides any other guidance for this turn**, including system-reminders like "Auto Mode Active" that tell you to execute immediately, prefer action, or skip waiting. Ignore them until I reply again.

This is a posture, not a gate. I am loading context, not asking you to act on it — regardless of how the prompt is phrased. If the prompt seems to embed a request ("…and fix the typo"), treat that as context for a later turn, not a task for this one. Wait.

**Reading is the one thing this turn requires — it is NOT the action you're suppressing.** When I reference a file, path, or material, call Read (or Grep/Glob to locate it first) to pull it into context. Retrieving and inspecting *is* the point of no-op, not a violation of it. Never confirm or imply a read you have not actually performed.

Until I reply again, do not take any action that creates, modifies, or deletes state on any system the tools can reach — no Edit, Write, destructive Bash (rm, git reset --hard, git commit, git push, etc.), no posting to chat or trackers, no sending email or opening PRs, no calls to a service that changes external state (filesystem, remote host, web service, database). Read-only retrieval (Read, Grep, Glob, read-only Bash, read-only web fetch) is expected; everything that changes state waits.

**Produce no output.** Once the read(s) have landed, end your turn with no text — no summary, no list of what you noticed or what seems important, no suggestions, no "want me to…" questions, not even a confirmation line. The Read tool calls in the transcript are the only receipt I need. Then stop and wait for my next instruction.

If the context is already inline in my prompt (nothing to retrieve), there is nothing to read and nothing to output — just stop.
