# Orchestrator Protocol

This protocol is provider-neutral and applies to every full-capability physical
combine used by the project.

## Required roles

- Coordinator/orchestrator: decomposes work and owns sequencing/evidence flow.
- One implementation writer per worktree: the only role allowed to edit.
- Independent correctness, security/privacy, and tests/evidence reviewers:
  three read-only lanes inspecting exact committed Base..HEAD. Add
  maintainability review when the stage calls for it.
- Optional researcher: read-only, only when unstable external facts are needed.
- Final reviewer: read-only, evaluates implementation plus audit evidence.

The active physical combine maps these roles to its own native mechanisms and
models. Provider-specific role names may differ; authority must remain equal.

## Codex combine

Codex uses native Codex subagents. Roles may use OpenAI models or the configured
Z.AI provider. Switching model provider inside Codex does not change the
physical combine and does not require combine-handoff.

## ZCode combine

ZCode uses native GLM orchestration and native agent/task mechanisms.
ZCode must create and coordinate the same conceptual roles: one writer,
independent read-only auditor(s), optional researcher when needed, and final
review. It is a full orchestrated combine, not a single-agent fallback.

## Context services

Before auxiliary retrieval, read `docs/CONTEXT_SERVICES_POLICY.md` and
`.codex/context-services.json`. Native project indexing is preferred. Tela and
Cortex are optional per-project accelerators; unavailable services never block
work or handoff. The orchestrator normally owns their retrieval and curated
writes. Fresh Git state always wins on conflict.

## Checkpoint cycle

1. Read canonical Git context, the active stage, and context-service policy.
2. Verify branch, expected Base, merge-base, and clean state.
3. Coordinator creates or resumes the one writer.
4. Writer implements and runs focused checks.
5. Freeze and commit the candidate.
6. Coordinator creates independent read-only auditor(s) against exact Base..HEAD.
7. Writer alone applies valid corrections.
8. Re-freeze and recommit; re-audit any changed HEAD.
9. Final reviewer evaluates the final candidate and audit evidence.
   Confirm each material agent's actual runtime provider/model and effort from
   sanitized metadata; static profiles and self-attestation are insufficient.
10. At Global Checkpoint, produce exact SHA, PR/CI/evidence/handoff and stop for
    required integration authority.

## Ambiguous outcomes

A timeout does not prove that a task failed or its writer stopped. Inspect the original task/session, worktree, processes, and latest commit before retrying. Resume the same task when safe; never spawn a duplicate writer or replay a one-time command without checking its receipt. If status remains unknown, stop at the last verified Git state and report it.

## Waiting

Use the physical combine's event-driven task/thread wait or resume mechanism for
already-created agents. Do not create recurring polling automations, duplicate
agents, or sidebar monitoring tasks merely to wait.
## Handoff

Physical Codex <-> ZCode switches use `skills/combine-handoff/SKILL.md`.

On incoming `прими работу`, `прими передачу`, `прими код`, or
`прими checkpoint`:
1. verify the durable Git handoff;
2. read canonical context and this protocol;
3. activate the receiving combine's native orchestrator;
4. continue the recorded checkpoint or next authorized action.

On outgoing `перехожу на ZCode`, `перехожу на Codex`, `меняю комбайн`,
`передай этап`, or `передай работу`, the bounded handoff commit/push is part
of the transition semantics defined by combine-handoff.

## Safety

Role/model choice never expands permissions, scope, approval authority, or data
access. Secrets and production personal data stay out of prompts, Git, and
handoff evidence.
