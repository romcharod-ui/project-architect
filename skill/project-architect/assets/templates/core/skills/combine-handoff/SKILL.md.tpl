---
name: combine-handoff
description: Prepare or accept a safe handoff between physical development combines such as Codex and ZCode.
---

# Combine Handoff

Use this skill when the owner changes the physical execution combine.

Recognized outgoing phrases include:
- `перехожу на ZCode`
- `перехожу на Codex`
- `меняю комбайн`
- `передай этап`
- `передай работу`

Recognized incoming phrases include:
- `прими работу`
- `прими передачу`
- `прими код`
- `прими checkpoint`

Do not use this skill for a model-provider switch inside Codex. Selecting GLM
instead of Luna/Sol while remaining in the Codex application is model routing,
not a combine handoff.
## Authorization semantics

An explicit outgoing handoff phrase from the owner authorizes the bounded
handoff operations needed to transfer the current checkpoint:
- update factual handoff/context files when needed;
- create the handoff commit on the current handoff/stage branch;
- push that exact branch state to `origin`;
- report the exact pushed SHA.

It does not authorize merge to the default branch, deployment, release,
production mutation, destructive cleanup, or starting a new unapproved stage.

An incoming phrase authorizes fetch/pull/read/verification of the recorded
handoff boundary and activation of the receiving combine's native orchestrator
for the already-approved checkpoint or next action recorded in the handoff.

## Invariants

- Only committed and pushed Git state crosses a physical combine boundary.
- One checkpoint belongs to one active physical combine.
- Provider-neutral roles cross the boundary; provider-specific aliases do not.
- The receiving combine maps coordinator, writer, auditor(s), optional
  researcher, and final reviewer to its own native agents/models.
- ZCode is a full orchestrated combine, not a single-agent fallback.
## Outgoing handoff

1. Fetch `origin` and record branch, exact HEAD, merge-base, and worktree state.
2. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, `ROADMAP.md`,
   `docs/TOOL_HANDOFF_POLICY.md`, `docs/CONTEXT_SERVICES_POLICY.md`,
   `.codex/context-services.json`, and `docs/ORCHESTRATOR_PROTOCOL.md`.
3. Finish the current checkpoint or record a deliberate stopping point.
4. Update `PROJECT_CONTEXT.md` only when accepted factual state changed.
5. Create `docs/handoffs/YYYY-MM-DD-<from>-to-<to>.md` from the handoff template.
6. Update `docs/handoffs/LATEST.md`.
7. Run required focused checks plus `git diff --check`.
8. Commit the bounded handoff state and push the current branch to `origin`.
9. Verify the pushed SHA and expected clean worktree state.
10. Report branch, pushed SHA, checkpoint status, checks, handoff file, risks,
    and the receiving combine's intake instruction.

## Incoming handoff

1. Fetch `origin`.
2. Read `docs/handoffs/LATEST.md` and identify the recorded branch/SHA.
3. Check out the recorded branch and pull with `--ff-only`.
4. Verify clean worktree, exact SHA, and approved reachability.
5. Read `PROJECT_CONTEXT.md`, `AGENTS.md`, `ROADMAP.md`,
   `docs/TOOL_HANDOFF_POLICY.md`, `docs/CONTEXT_SERVICES_POLICY.md`,
   `.codex/context-services.json`, `docs/ORCHESTRATOR_PROTOCOL.md`, and the
   referenced handoff file. Auxiliary services remain optional/non-blocking.
6. Confirm source combine, checkpoint state, risks, tests, and next action.
7. Activate the receiving combine's native orchestrator. It creates one native
   writer for the worktree, independent native read-only auditor(s), optional
   researcher only when needed, and a native final reviewer according to
   `docs/ORCHESTRATOR_PROTOCOL.md` and current model routing.
8. Do not begin a different stage or expand scope beyond the handoff.

## Physical-combine behavior

### Codex receive

Use native Codex agents and configured OpenAI/Z.AI routing. A model switch
inside Codex does not require another handoff.

### ZCode receive

Use ZCode's native GLM orchestrator and agent/task mechanisms. ZCode continues
as an orchestrated multi-agent combine with one writer, independent read-only
auditor(s), and final review. Do not collapse it into a single general-purpose
agent.
