# Usage

## Coordinate in the active ChatGPT conversation

Read CHAT_START.md from a pinned foundation release/commit. The coordinating
chat prepares owner-reviewed PROJECT_BRIEF.md, FOUNDATION_PLAN.md, and the exact
bootstrap prompt.

## Install the skill

Install skill/project-architect into the profile that will execute bootstrap.
Windows-native and WSL Codex profiles have separate skill directories.

## Two routing axes

Physical combine:
- Codex application.
- ZCode application.

Model provider inside Codex:
- OpenAI.
- an authorized custom provider such as Z.AI.

Changing OpenAI <-> Z.AI models while staying in Codex is model routing, not a
combine handoff. Changing Codex <-> ZCode is a physical combine handoff.

## Native GLM profiles in Codex

Generated projects include native Codex agent profiles for:
- GLM-5.3/max implementation, audit, and final review;
- GLM-5.3-Flash/max implementation and audit.

They use model_provider = zai_coding and preserve the same role permissions as
their OpenAI equivalents. The provider definition and API key remain user-level
configuration and are never generated into the repository.

If zai_coding is unavailable on a machine, the GLM profiles are unavailable but
the repository foundation remains valid.

## Auditor behavior

Ordinary Luna and GLM auditors are native Codex subagents and are read-only.
Freeze/commit the candidate before requesting a verdict, and wait for existing
agents using event-driven wait/resume.

Do not create recurring monitoring automations and do not start nested Codex CLI
processes solely to obtain a normal audit.

## Physical combine handoff

Use skills/combine-handoff/SKILL.md to move between Codex and ZCode. Transfer
only committed/pushed Git state plus canonical handoff documents.

## Optional context services

Generated projects always include `docs/CONTEXT_SERVICES_POLICY.md` and a
non-secret `.codex/context-services.json`. Native project indexing is preferred.
Tela and Cortex stay disabled unless that project explicitly opts in.

Use `--project-key <slug>` plus `--tela-space <space-ref>` and/or
`--cortex-namespace project:<slug>` to enable them. Credentials remain outside
Git. Tela/Cortex are auxiliary only: Git wins conflicts and service failure must
never block development, audit, CI, or handoff.

## Direct bootstrap

Use Python 3.11 or newer, then run:

python3 scripts/bootstrap_project.py --target <project> --brief <brief> \
  --foundation-plan <plan> --project-name <name> --profile generic --dry-run

Inspect the dry-run, run again without --dry-run, then:

python3 scripts/validate_project.py --target <project>
python3 <project>/scripts/validate-model-routing.py

The generated GitHub workflow checks repository bindings at the exact PR
head. Native ZCode user profiles and actual agent routes require separate
host/runtime checks described in the generated routing documentation.

Bootstrap does not initialize a remote repository, push, merge, deploy, install
dependencies, or access production.
