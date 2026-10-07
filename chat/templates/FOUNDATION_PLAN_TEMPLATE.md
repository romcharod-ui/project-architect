# FOUNDATION PLAN — <Project name>

Status: `OWNER-APPROVED FOR BOOTSTRAP` or `DRAFT`

## Recommended profile

Choose `generic`, `node-postgresql`, or propose a future profile. Explain the
choice and assumptions. The active execution combine must verify the actual
environment.

## Proposed repository foundation

Describe canonical context, roadmap, stage files, reviewer contracts, CI/Git
controls, documentation, and verification structure.

## Architecture baseline to validate

Summarize proposed boundaries, modules, data ownership, authentication,
external adapters, deployment shape, and recovery. Clearly distinguish accepted
product decisions from technical recommendations still requiring approval.

## Initial Global Stages

Define architecturally coherent outcomes, dependencies, readiness gates, and
what each stage explicitly excludes. Select only the first stage for immediate
planning.

## Model routing and combines

Separate physical execution surface from model provider.

Physical combines:
- Codex application with native Codex subagents.
- ZCode application with native ZCode agents.

Inside Codex, record equivalent role profiles for OpenAI and authorized Z.AI
models. GLM writer/auditor/final-review roles must retain the same permissions
as their OpenAI counterparts. A GLM auditor is a normal native Codex subagent,
not an external-only adapter.

A user instruction to continue on GLM Max / GLM Flash Max changes model routing
inside Codex and does not trigger combine-handoff. Codex <-> ZCode does.

Ordinary audit uses native reviewer/subagent mechanisms, a committed candidate,
and event-driven waiting rather than polling timers or nested CLI audit
processes.

## Context and indexing services

Record Git as canonical truth and native project indexing as preferred. Decide
whether Tela semantic knowledge and Cortex curated durable memory are enabled
for this project. If enabled, record a stable project key plus dedicated Tela
space/reference and/or exact Cortex namespace `project:<project-key>`. Keep
credentials outside Git. Auxiliary-service failure must be non-blocking, and
fresh Git state wins every conflict.

## Verification and caches

Define aggregate and focused tests, integration/database proof, dependency
audits, independent CI, reusable caches, and disposable runtime. Do not hardcode
an incompatible OS/toolchain downloader.

## Security and authority gates

List actions requiring separate approval: remote creation, push/merge, external
systems, credentials, migration/deploy, production data, and destructive
recovery.

## Bootstrap write boundary

List only governance/foundation files to be generated before product
implementation.

## First execution stop

Bootstrap validates the foundation and stops before product code. The first
Global Stage begins only under a separate accepted stage contract.

## Remaining blockers

Must be empty for `OWNER-APPROVED FOR BOOTSTRAP`.
