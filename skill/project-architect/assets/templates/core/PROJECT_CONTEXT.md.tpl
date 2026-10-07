# PROJECT CONTEXT — {{PROJECT_NAME}}

Updated: {{DATE}}
Foundation profile: `{{PROFILE}}`

This file is the sole accepted long-lived source of project status and
decisions. Chat history, task summaries, and stale branches do not override it.

## Product purpose

The accepted product brief is `docs/product/PROJECT_BRIEF.md`. When present,
`docs/product/FOUNDATION_PLAN.md` records the owner-approved coordination plan;
Codex-generated implementation details still require acceptance through the
stage workflow.

Status: `FOUNDATION DRAFT — OWNER REVIEW REQUIRED`

## Current stage

- Foundation: `DRAFT`
- First product stage: `NOT SELECTED`
- Production/staging deployment: `NOT AUTHORIZED`
- External-system mutation: `NOT AUTHORIZED`

## Accepted scope

Derive the first accepted scope from the product brief and record it here only
after owner review.

## Explicit exclusions

Record features and environments that must not be started implicitly.

## Architecture baseline

Record only accepted architecture, data ownership, trust boundaries, runtime
components, and recovery constraints. Do not treat a generated suggestion as an
accepted decision.

## Security and privacy

Record applicable data classes, authentication boundaries, authorization,
retention, external transfers, logging restrictions, and deployment controls.

## Verification baseline

- Focused checks during implementation.
- One aggregate final application proof.
- One full integration/database proof when applicable.
- Dependency/security audits once per final candidate.
- Validated reusable caches are preserved; per-run runtime is cleaned.
- Independent exact-HEAD CI is required.

## Decision Log

No decisions have been accepted yet.

Decision IDs are project-global and never reused. A replaced decision is marked
`SUPERSEDED`; it is not deleted.

## Context synchronization

Update by merging accepted facts after review and integration. Preserve
unrelated decisions and history. A context-only commit must not alter reviewed
implementation artifacts.
