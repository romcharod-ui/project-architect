---
name: project-architect
description: Bootstrap a new Codex-managed software repository from an already discussed product brief, including canonical context, staged delivery, reviewer roles, model routing, Git controls, multi-combine handoff, and efficient verification. Use for founding or structurally upgrading a project; do not invoke for routine feature implementation.
metadata:
  short-description: Bootstrap a governed Codex project
---

# Project Architect

Turn an agreed product brief and, when supplied, an owner-approved Foundation
Plan into a maintainable project foundation. Do not invent product requirements,
choose irreversible architecture silently, or start feature implementation
before the foundation plan is accepted.

## Route the request

1. Read the complete product brief, supplied Foundation Plan, and existing
   repository instructions.
2. When a coordinating ChatGPT conversation produced both documents, treat
   their owner-approved decisions as inputs. Validate them for contradictions
   and technical feasibility; do not restart general product discovery.
3. If the inputs still have material product, data-ownership, privacy,
   deployment, or commercial gaps, list only the blocking decisions and stop.
4. Otherwise read [project discovery](references/project-discovery.md) and
   prepare a concise foundation plan: project profile, canonical context,
   stages, review lanes, verification, caches, and external boundaries.
5. Materialize the foundation only when the user has explicitly asked to
   bootstrap or approved that plan.
6. Read [operating model](references/operating-model.md) for repository, stage,
   reviewer, and multi-combine governance. Always read
   [model routing](references/model-routing.md) before configuring agents. It
   separates physical-combine selection from model-provider routing: Codex may
   use OpenAI or Z.AI/GLM native subagents, while ZCode is a separate physical
   combine reached through Git handoff. Role permissions remain model-neutral.
   Read
   [verification policy](references/verification-policy.md) when selecting a
   technology profile or generating test tooling.
7. When multiple physical execution combines are authorized, materialize the
   provider-neutral combine-handoff skill and tool handoff policy. Do not use a
   physical handoff for OpenAI <-> GLM model changes inside Codex.

## Bootstrap

Use Python 3.11 or newer for bootstrap validation and the generated routing
checker (`tomllib` is in the standard library).

Use `scripts/bootstrap_project.py` instead of manually copying templates:

```text
python3 <skill-dir>/scripts/bootstrap_project.py \
  --target <project-directory> \
  --brief <product-brief.md> \
  --foundation-plan <foundation-plan.md> \
  --project-name <name> \
  --profile <generic|node-postgresql> \
  [--project-key <stable-project-slug>] \
  [--tela-space <dedicated-space-ref>] \
  [--cortex-namespace project:<stable-project-slug>] \
  --dry-run
```

Inspect the dry-run. Then run without `--dry-run` only within the user-approved
target. The script refuses to overwrite different files. Never weaken that
boundary to make bootstrap succeed; reconcile existing files explicitly.

After generation run:

```text
python3 <skill-dir>/scripts/validate_project.py --target <project-directory>
python3 <project-directory>/scripts/validate-model-routing.py
```

The generated foundation is a starting contract. An owner-approved Foundation
Plan is authoritative product/coordination input, but generated technical
details remain proposals until accepted. Record the first stage and obtain its
approval before product implementation.

Bootstrap also installs `skills/combine-handoff/SKILL.md`, its handoff template,
`docs/TOOL_HANDOFF_POLICY.md`, `docs/CONTEXT_SERVICES_POLICY.md`,
`.codex/context-services.json`, and the handoff pointer. Tela/Cortex are disabled
unless the project explicitly opts in with bootstrap flags. Project Architect
configures these protocols; the project-local combine-handoff skill performs
the actual outgoing and incoming transitions.

## Invariants

- PROJECT_CONTEXT.md is the accepted long-lived project state once adopted.
- One writer owns a worktree. Auditors are read-only.
- Separate physical-combine routing from model-provider routing.
- The Codex combine may use OpenAI or Z.AI/GLM native subagents. The generated
  GLM writer/auditor/final-review profiles use model_provider = zai_coding.
- GLM auditors have the same read-only sandbox/approval contract as Luna
  auditors. They are not reduced external adapters.
- ZCode is a separate physical combine. Codex <-> ZCode changes use
  combine-handoff; OpenAI <-> GLM changes inside Codex do not.
- Ordinary audit uses native reviewer/subagent mechanisms. Do not launch nested
  Codex CLI sessions solely for routine audit.
- Freeze and commit the candidate before an audit verdict. If HEAD changes,
  review the new candidate.
- Wait on existing agents through event-driven wait/resume. Do not create
  recurring polling automations or duplicate delayed agents.
- Explicitly bind deliberate model/provider choices; do not rely on accidental
  inheritance. The default Codex roles are GPT-6 Sol/high for coordinator and
  final judge, GPT-6 Luna/high for writer and ordinary reviewers, and
  GPT-6 Luna/low for researcher. ZCode defaults are GLM-5.3/max for
  coordinator/final and GLM-5.3-Flash/max for writer/ordinary reviewers.
  Native ZCode user profiles must be provisioned and checked on that host
  separately, following generated `docs/codex/ZCODE_NATIVE_PROFILES.md`.
- Correctness, security/privacy, and tests/evidence reviewers are independent
  required lanes at every checkpoint. Validate static bindings, then retain
  sanitized runtime provider/model evidence for every material agent.
- Model choice never expands or reduces role permissions, scope, or evidence.
- Separate disposable test runs from long-lived preview and persistent data; record exact cleanup.
- After a timeout, inspect the original task before retrying; never duplicate a writer.
- Cite only logs actually retained and verify UI interactions in the target environment when available.
- Preserve verified dependency/toolchain caches and delete disposable runtime
  state only.
- Git is the canonical context authority. Native indexing is preferred; Tela
  semantic knowledge and Cortex durable memory are optional per-project layers.
  Their failure never blocks work or handoff, and conflicts resolve in favor of
  fresh Git state.
- Keep auxiliary context project-isolated and data-minimized. Do not store
  secrets, `.env`, personal data, raw logs, full diffs, or chat dumps in Tela or
  Cortex. Orchestrators own normal auxiliary retrieval/curated writes; direct
  subagent access is opt-in by need.
- Never create remote repositories, push, merge, deploy, access production, or
  install globally without the required authority.
- Keep secrets, credentials, private keys, production payloads, and personal
  data out of prompts, Git, evidence, and logs.

Stop for the user when a choice changes product scope, architecture, data
ownership, privacy posture, payment behavior, deployment authority, migration
safety, or an existing repository's accepted decisions.
