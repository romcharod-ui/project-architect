# Tool Handoff Policy

This policy governs switching the physical execution combine.

Physical combines:
- Codex combine: ChatGPT/Codex application and native Codex subagents.
- ZCode combine: separate ZCode application and native ZCode agents.

Model-provider changes inside Codex are not combine changes. Switching a Codex
role between OpenAI and Z.AI/GLM does not use combine-handoff.

Invoke `skills/combine-handoff/SKILL.md` for outgoing phrases such as
`перехожу на ZCode`, `перехожу на Codex`, `меняю комбайн`,
`передай этап`, or `передай работу`.

Invoke it for incoming phrases such as `прими работу`, `прими передачу`,
`прими код`, or `прими checkpoint`.

For a physical combine handoff:
1. Finish the checkpoint or record a deliberate stopping point at a known SHA.
2. Commit and push the bounded owner-authorized handoff state.
3. Update canonical context and the handoff record as needed.
4. The receiving combine fetches/pulls, verifies SHA and clean worktree, reads
   canonical context and `docs/ORCHESTRATOR_PROTOCOL.md`, then activates its
   native orchestrator and agents.
5. Chat history and local caches are not sources of truth across the boundary.

Codex and ZCode must not write simultaneously in the same physical checkout.
Prefer separate worktrees/checkouts.

Inside Codex, OpenAI and Z.AI models may be mixed across roles when explicitly
routed. Role permissions remain unchanged by provider. The project-local GLM
agent profiles use user-level `zai_coding`; credentials never belong in Git.

ZCode remains a full orchestrated combine with native writer, auditor(s), and
final review. It must not degrade to a single-agent continuation.
