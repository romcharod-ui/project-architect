# Multi-combine operating contract: {{PROJECT_NAME}}

PROJECT_CONTEXT.md on the fresh default branch is the canonical source of
accepted project state, decisions, scope, and invariants.

## Significant-task start gate

1. Fetch the canonical remote without rewriting history.
2. Report the exact default-branch SHA and compare it with the assigned Base.
3. Stop on context drift; do not silently rebase or redesign.
4. Read PROJECT_CONTEXT.md, ROADMAP.md, the assigned stage, and applicable
   project protocols.
5. Require a clean worktree and exact merge-base before implementation.

## Roles and authority

- One writer owns a worktree.
- Auditors are independent and read-only.
- A final reviewer is read-only.
- The writer never creates or controls its own auditors.
- Model/provider choice never changes role permissions, scope, evidence, or
  integration authority.
- Push, merge, release, deploy, production access, destructive migration, and
  external-system mutation require the authority defined by the project.

## Two routing axes

Physical combine and model provider are separate.

- Codex combine = current ChatGPT/Codex application plus native Codex subagents.
- ZCode combine = separate ZCode application plus its native agents.
- Inside the Codex combine, roles may use OpenAI models or the authorized
  Z.AI custom provider. This does not require a combine handoff.
- Switching the physical application Codex <-> ZCode does require
  combine-handoff at a durable Git boundary.

## Default model-routing matrix

These defaults apply prospectively to new project work. Specialized review
focus does not automatically raise model seniority. Record deliberate
substitutions and verify the actual runtime route.

| Conceptual role | Codex combine default | ZCode combine default |
|---|---|---|
| coordinator / architect | GPT-6 Sol / high | GLM-5.3 / max |
| implementation writer | GPT-6 Luna / high | GLM-5.3-Flash / max |
| correctness auditor | GPT-6 Luna / high | GLM-5.3-Flash / max |
| security/privacy reviewer | GPT-6 Luna / high | GLM-5.3-Flash / max |
| tests/evidence reviewer | GPT-6 Luna / high | GLM-5.3-Flash / max |
| maintainability reviewer | GPT-6 Luna / high | GLM-5.3-Flash / max |
| researcher | GPT-6 Luna / low | GLM-5.3-Flash / max |
| final judge | GPT-6 Sol / high | GLM-5.3 / max |

## Codex model profiles

- `implementation_worker`: GPT-6 Luna/high, workspace-write.
- `luna_auditor`, `auditor`, `security_reviewer`, `test_reviewer`, and
  `maintainability_reviewer`: GPT-6 Luna/high, read-only.
- `web_researcher`: GPT-6 Luna/low, read-only.
- `final_judge`: GPT-6 Sol/high, read-only.
- Optional `glm_implementation_worker` and `glm_flash_implementation_worker`
  use `zai_coding` and workspace-write; GLM auditor/final profiles are read-only.
  `glm_flash_auditor` has the same sandbox and approval permissions as
  `luna_auditor`. GLM profiles are native Codex alternatives, not ZCode agents.

The `zai_coding` provider and credentials are user-level Codex settings; never
put them in Git. No combine-handoff is needed for a model change inside Codex.
The bounded OpenAI fallback is GPT-6 Luna -> GPT-6 Sol. GPT-6.1 Sol and
GPT-6 Astra are manual owner CENTRAL selections only, never automatic defaults.
GPT-6 Terra is not an exposed model. Preserve historical executed model labels.

ZCode native user profiles select child models. Its coordinator/final judge use
GLM-5.3/max; writer and ordinary reviewers use GLM-5.3-Flash/max. Check those
native profiles on each ZCode host separately from repository/CI validation;
follow `docs/codex/ZCODE_NATIVE_PROFILES.md`.
Never infer a child model from the coordinator model.

## Auditor orchestration

Use the active physical combine's native reviewer/subagent mechanism for
ordinary audits. In Codex, this applies equally to Luna and GLM auditors.

Do not launch nested codex exec solely for routine internal audit when native
subagents exist.

Finish the writer correction loop and commit the candidate before requesting an
audit verdict. The correctness, security/privacy, and tests/evidence review
lanes are independent and mandatory for each checkpoint. Bind the review to
exact Base..HEAD. If HEAD changes, re-review the new candidate.

Wait on already-created agents using event-driven wait/resume. Do not create
recurring polling automations, sidebar monitoring tasks, or duplicate delayed
reviewers.

Run `python3 scripts/validate-model-routing.py` in the repository. It parses
Codex profiles and checks this matrix. For native ZCode profiles use the
explicit `--zcode-dir`/`--zcode-prefix` local check. Record sanitized runtime
provider/model evidence for coordinator, writer, every reviewer and final judge;
self-reports and static checks do not prove actual routing. A material route
mismatch invalidates that lane's verdict. Never record raw request bodies or
credentials.

A separate process-isolated audit is an optional stronger assurance mode used
only when the stage or owner explicitly requires it.

## Multi-combine handoff

Invoke `skills/combine-handoff/SKILL.md` immediately when the owner says an
outgoing phrase such as `перехожу на ZCode`, `перехожу на Codex`, `меняю
комбайн`, `передай этап`, or `передай работу`, or an incoming phrase such as
`прими работу`, `прими передачу`, `прими код`, or `прими checkpoint`.

Use combine-handoff only for changing the physical combine, for example
Codex -> ZCode or ZCode -> Codex. Do not invoke it merely because Codex changes
from an OpenAI model to a Z.AI/GLM model or back.

On receive, after Git-boundary verification, activate the receiving combine's
native orchestrator under `docs/ORCHESTRATOR_PROTOCOL.md`. ZCode continues with
its native orchestrator and agents rather than as a single agent.

One checkpoint belongs to one physical combine. Transfer only through the
durable Git boundary defined in `docs/TOOL_HANDOFF_POLICY.md`.

## Context services

Git is authoritative. Read `docs/CONTEXT_SERVICES_POLICY.md` and
`.codex/context-services.json` before using auxiliary context services.
Native project indexing is preferred when available. Tela is optional semantic
knowledge; Cortex is optional curated durable memory. Neither is required for
development, audit, CI, or handoff.

The coordinator/orchestrator owns ordinary Tela/Cortex retrieval and curated
writes. Writers and auditors do not receive direct auxiliary-service access by
default. Keep projects isolated by the configured Tela space and Cortex
namespace, minimize data, and never store secrets, `.env`, personal data, raw
logs, full diffs, or chat dumps there. If auxiliary context conflicts with fresh
Git state, Git wins. Service failure is non-blocking.

## Stage execution

- Work on one architecturally coherent Global Stage.
- Materialize exact scope, write set, exclusions, checkpoints, tests, and
  recovery before product implementation.
- Run focused affected checks while iterating.
- Review the exact candidate and correct valid findings.
- Stop for product, architecture, privacy, security, dependency, migration,
  production, or scope forks.

## Efficient verification

Follow docs/codex/LOCAL_VERIFICATION.md and any profile-specific verification
contract. Preserve validated caches and remove disposable runtime state only.
Independent exact-HEAD CI remains required.

## Global hard stop

At the Global Checkpoint, publish only the exact branch/PR authorized by the
task, provide the handoff, and stop. Do not merge, change the default branch, or
start the next stage without the required authority.

## Safety

Never expose secrets, credentials, private keys, production payloads, or
personal data in prompts, Git, evidence, or logs. Preserve unrelated user
changes.
