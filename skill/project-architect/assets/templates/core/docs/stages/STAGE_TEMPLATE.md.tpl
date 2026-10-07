# <Stage ID> — <Architecturally complete outcome>

Model: <model> · Effort: <level>
Fallback: <ordered fallback>

## Authority and identities

- Canonical Base: `<exact SHA>`
- Required branch: `<branch>`
- Implementation authority: `<granted scope>`
- Integration authority: `NOT GRANTED` unless explicitly stated
- Parent Implementer: only writer

## Goal

Describe one independently valuable outcome.

## Accepted behavior

List observable product and system contracts.

## Architecture and data ownership

Record sources of truth, trust boundaries, invariants, migrations, external
systems, and recovery.

## Exact write set

List every allowed path. Stop for additions outside the write set.

## Explicit exclusions

List work that this stage must not begin.

## Internal checkpoints

Define bounded implementation slices and focused verification.

## Required checks

Define final aggregate, integration/database, audit, cleanup, Git, and CI proof.

## Required read-only review

Choose only the lanes justified by actual risk and declare model/effort.

## Global hard stop

Publish exact branch/PR/CI evidence and return `AWAITING CENTRAL APPROVAL`.
Do not merge, modify the default branch, deploy, or start the next stage.
