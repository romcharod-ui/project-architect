# Project discovery

Use this reference before generating a new foundation.

When a coordinating ChatGPT conversation has already produced an
owner-approved Product Brief and Foundation Plan, use this checklist to validate
coverage and contradictions. Do not ask the owner to repeat settled discussion.

## Required brief outcomes

The brief should establish, at the level relevant to the intended first
release:

- users and primary jobs;
- accepted and explicitly excluded scope;
- core workflows and success criteria;
- data owners and sources of truth;
- anonymous, authenticated, operator, and administrator boundaries;
- sensitive or regulated data;
- external systems and who authorizes them;
- expected deployment environments;
- recovery expectations;
- known stack choices and open technical choices.

Do not demand decisions that have no effect on the first stages. Mark harmless
unknowns as deferred. Stop only for gaps that would materially change the
foundation or authorize a risky action.

## Existing repositories

Read all applicable `AGENTS.md` files and the current accepted context before
proposing changes. Preserve useful existing controls. Bootstrap is not
authorization to replace CI, rewrite history, rename branches, change package
management, or discard local conventions.

## Foundation plan

Before generation report:

1. chosen profile and why;
2. canonical context and decision-log location;
3. initial stages and the first implementation gate;
4. provider-neutral writer, auditor, researcher, and final-review roles,
   including permissions and independent sibling topology;
5. physical-combine choices plus per-role model/provider bindings inside each
   combine, inheritance policy, recreation rules, and bounded fallbacks;
6. context-service policy: Git canonical, native indexing preferred, and whether
   Tela/Cortex are disabled or explicitly enabled with isolated project refs;
7. verification commands and cache boundaries;
8. Git/CI integration boundary;
9. deferred choices and explicit exclusions.

If an approved Foundation Plan already covers these points coherently, confirm
it concisely instead of producing a competing plan.
