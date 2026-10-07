# Context Services Policy

Git is the authoritative project state. `PROJECT_CONTEXT.md`, accepted stage
documents, committed code, and exact Git identities override every auxiliary
memory or semantic-index service.

Native project indexing in the active combine is preferred when available.
Auxiliary services are optional accelerators and must never become prerequisites
for development, review, CI, or Codex <-> ZCode handoff.

Project opt-in is recorded in `.codex/context-services.json`. Bootstrap stores
only non-secret identifiers there. OAuth tokens, API keys, cookies, credentials,
and provider configuration remain user-level or service-managed.

## Tela

Tela is an optional semantic documentation and retrieval layer.

Suitable content:
- architecture overviews and durable explanations;
- accepted decision summaries already represented canonically in Git;
- stage summaries, troubleshooting notes, and operational documentation;
- searchable references whose loss would not make Git incomplete.

Do not treat Tela as a source of integration authority. Do not upload secrets,
`.env` files, credentials, private keys, production payloads, personal data,
raw database dumps, whole chat transcripts, raw logs, or indiscriminate full
repository/diff copies.

Use a dedicated project space/reference. Never search or write another
project's space merely because it is available to the same account.

## Cortex

Cortex is an optional curated durable-memory layer.

Store only compact, durable facts such as accepted constraints, conventions,
decision summaries, and supersession relationships. Use the exact project
namespace recorded in `.codex/context-services.json`.

Do not use Cortex as a transcript store, code archive, log store, issue tracker,
or replacement for canonical project documents. Do not write hypotheses,
unreviewed reviewer findings, temporary failures, transient HEADs, secrets,
credentials, personal data, raw logs, full diffs, or chat dumps.

A Cortex memory must be traceable to accepted Git state or a clearly identified
owner decision. When that state changes, update or supersede the memory rather
than allowing stale memory to silently guide later work.

## Access and agent policy

The coordinator/orchestrator may use enabled context services for recall,
semantic search, and carefully curated writes.

Writers and auditors should receive the minimal relevant context through normal
project files or the orchestrator. Direct Tela/Cortex access is not a default
capability for every subagent; enable it only when the task genuinely requires
independent retrieval and the role remains within its read/write authority.

Context-service failure is non-blocking. Continue from Git and native project
indexing. Never weaken verification, skip canonical reads, or delay handoff
solely because Tela or Cortex is unavailable.

## Conflict handling

If Git and an auxiliary service disagree:
1. stop relying on the conflicting auxiliary entry;
2. verify fresh canonical Git state;
3. follow Git;
4. correct/supersede the auxiliary entry when authorized.

No auxiliary service may authorize scope expansion, merge, deployment,
production access, migration, credential use, or destructive recovery.
