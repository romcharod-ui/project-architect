# Combine Handoff

## Direction

- From combine:
- To combine:
- Date:
- Checkpoint status: completed | deliberately stopped

## Git state

- Branch:
- Handoff commit SHA:
- Remote status: pushed to `origin/<branch>` | not pushed (state why)
- Working tree at handoff:

## Completed work

Describe the completed checkpoint or the deliberate stopping point.

## Changed files

- `path/to/file` — purpose

## Verification

- Check run: result
- Check not run: reason

## Decisions accepted

- Decision and canonical reference

## Open risks / follow-ups

- Risk or follow-up, owner if known

## Next recommended action

State the next checkpoint and its boundary. Do not start it automatically.

## Required intake checks

- Fetch `origin`, check out the recorded branch, and pull with `--ff-only`.
- Verify a clean working tree and the recorded SHA.
- Read `PROJECT_CONTEXT.md`, `AGENTS.md`, `ROADMAP.md`,
  `docs/TOOL_HANDOFF_POLICY.md`, `docs/CONTEXT_SERVICES_POLICY.md`,
  `.codex/context-services.json`, `docs/handoffs/LATEST.md`, and this file.
- Treat Tela/Cortex availability as optional; never block intake if an enabled
  auxiliary context service is unavailable.
- Verify that the handoff commit is reachable from `origin/main` or the
  owner-approved branch.

## Notes / omissions

Record substitutions, skipped checks, dirty state, SHA mismatches, unpushed
commits, or intentionally omitted information. Do not include secrets, tokens,
credentials, or personal data.
