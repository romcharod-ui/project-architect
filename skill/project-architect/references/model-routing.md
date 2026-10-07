# Model routing and execution combines

Model routing and execution-combine selection are two different axes.

- The Codex combine is the current ChatGPT/Codex application and its native
  subagent/thread orchestration.
- Inside the Codex combine, a role may use either OpenAI models or an authorized
  custom provider such as Z.AI. Changing model/provider does not require a
  combine handoff.
- The ZCode combine is a separate physical execution application. Moving
  between Codex and ZCode does require combine-handoff at a durable Git boundary.

Model choice never changes a role's permissions, scope, evidence requirements,
or integration authority.

## Provider-neutral roles

| Role | Authority |
|---|---|
| coordinator | decomposes work and coordinates evidence; non-writing while orchestrating |
| implementation writer | sole writer for one assigned worktree |
| auditor(s) | independent read-only review of exact committed Base..HEAD |
| optional researcher | read-only research/support |
| final reviewer | read-only adjudication after implementation and audit evidence |

The role contract is primary. A model/provider is a replaceable execution
binding for that role.

## Native Codex profiles

The generated .codex/agents profiles let the same Codex application route roles
to either provider.

OpenAI defaults:

| Profile | Model / effort | Permission |
|---|---|---|
| implementation_worker | GPT-6 Luna / high | workspace-write |
| luna_auditor | GPT-6 Luna / high | read-only |
| auditor | GPT-6 Luna / high | read-only |
| security_reviewer | GPT-6 Luna / high | read-only |
| test_reviewer | GPT-6 Luna / high | read-only |
| maintainability_reviewer | GPT-6 Luna / high | read-only |
| web_researcher | GPT-6 Luna / low | read-only |
| final_judge | GPT-6 Sol / high | read-only |

Z.AI alternatives inside the same Codex combine:

| Profile | Provider / model / effort | Permission |
|---|---|---|
| glm_implementation_worker | zai_coding / GLM-5.3 / max | workspace-write |
| glm_flash_implementation_worker | zai_coding / GLM-5.3-Flash / max | workspace-write |
| glm_auditor | zai_coding / GLM-5.3 / max | read-only |
| glm_flash_auditor | zai_coding / GLM-5.3-Flash / max | read-only |
| glm_final_judge | zai_coding / GLM-5.3 / max | read-only |

The GLM auditor profiles deliberately have the same sandbox and approval
contract as luna_auditor. They are not reduced external adapters.

These GLM profiles set model_provider = zai_coding and require that user-level
Codex provider to be configured and authenticated. Project bootstrap never writes credentials or
user-level provider secrets. If the provider is not available, the GLM profiles
are simply unavailable; the repository remains valid.

## Switching models inside Codex

An owner instruction such as "from now on use GLM Max and GLM Flash Max" is a
model-routing change inside the Codex combine. It does not trigger
combine-handoff.

The coordinator may route subsequent roles to the native GLM profiles according
to task fit while preserving the exact role permissions. Report actual model
and provider use in the handoff/evidence.

Likewise, returning from GLM to Luna/Sol is a model-routing change, not a
physical-combine switch.

## OpenAI bounded fallback

For bounded OpenAI work, the operative fallback is GPT-6 Luna -> GPT-6 Sol.
Architecture, privacy, security, payments, authentication, destructive
migration, concurrency/data integrity, canonical conflict, and scope expansion
remain coordinator decisions. GPT-6.1 Sol and GPT-6 Astra are manual owner
selections for CENTRAL only, never automatic role defaults or fallback targets.
GPT-6 Terra is not an exposed model. Generation-6 defaults apply prospectively;
historical checkpoint evidence retains the models actually used.

## Default cross-combine matrix

The following defaults are installed for new projects. Specialized focus never
implies a senior-model upgrade; any substitution needs an explicit reason and
fresh routing evidence.

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

## Reviewer orchestration

Ordinary auditors run as native subagents of the active physical combine. In
Codex, that means native Codex subagents whether the selected auditor model is
Luna, GLM-5.3, or GLM-5.3-Flash.

Do not create a nested codex exec or second orchestrator solely to simulate an
audit when native subagents are available.

Freeze and commit the candidate before requesting a verdict. The correctness,
security/privacy, and tests/evidence lanes are independent and mandatory at
each checkpoint; maintainability is additional when relevant. Auditors receive
exact Base, candidate HEAD, branch, stage, changed paths, risks, and evidence.
If HEAD changes after corrections, the previous verdict remains attached to the
old HEAD and the new candidate must be reviewed.

Wait for existing agents through the combine's event-driven wait/resume
mechanism. Do not create recurring polling automations or duplicate delayed
reviewers.

A separately process-isolated audit may still be requested for a specific
high-assurance stage, but it is an additional isolation mode, not the normal
definition of a GLM auditor.

## ZCode physical combine

ZCode is a separate full-capability execution application. The coordinator and
final judge default to GLM-5.3/max. Its native writer, correctness, security,
test, and optional maintainability/research profiles default to
GLM-5.3-Flash/max. The native ZCode profiles in the user's app are authoritative
for child-agent model selection; repository `.codex/agents` aliases do not
control ZCode. Never infer a child model from its parent.

The generated `scripts/validate-model-routing.py` checks repository Codex
profiles by parsing TOML. On a ZCode host, run it separately with
`--zcode-dir <native-profile-dir> --zcode-prefix <project-slug>` to check native
ZCode profiles, including model, effort, AGENTS injection, and read-only tool
permissions. The generated `docs/codex/ZCODE_NATIVE_PROFILES.md` gives the
host setup sequence. Do not copy credentials or user-level provider settings into Git.
A billing plan may change while the approved model matrix remains stable.
Repository or CI PASS is not a claim that native ZCode profiles were checked.

Physical handoff follows `skills/combine-handoff/SKILL.md`.

## Explicit binding

Never rely on parent-model inheritance for a role whose model/provider was
chosen deliberately. Verify runtime provider/model evidence for material
agents, including coordinator, writer, each reviewer and final judge. Where
supported also check
effort and request status. Static profile PASS and agent self-attestation do
not prove the actual runtime route. Record only sanitized metadata, not prompts,
response bodies, credentials or raw model-I/O logs. A wrong route invalidates
that lane; correct it and rerun on the same frozen HEAD.

Model names and provider ids are versioned routing configuration. Revalidate
availability when updating the foundation; never silently redesign routing in
the middle of a product stage.
