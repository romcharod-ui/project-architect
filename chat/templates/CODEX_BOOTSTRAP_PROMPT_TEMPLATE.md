# Codex bootstrap prompt template

The coordinating chat fills all angle-bracket fields and removes unused notes.

```text
You are performing an owner-approved project foundation bootstrap.

Model: <architecture-capable model>
Effort: <minimum reliable effort>

Install or load $project-architect from:

Repository: <owner/repository or release archive URL>
Pinned release or commit: <exact tag or SHA>
Skill subdirectory: skill/project-architect

Do not use a moving branch in place of the pinned identity.

Target project directory:

<absolute path supplied by the owner>

Inputs:

- <absolute path to PROJECT_BRIEF.md>
- <absolute path to FOUNDATION_PLAN.md>

Read both inputs completely. Treat OWNER-APPROVED content as product authority.
Verify internal consistency and stop only for a real contradiction, security or
data-ownership gap, incompatible environment, or required authority not granted.
Do not restart general product discovery.

Use profile:

<generic or node-postgresql>

First run bootstrap in dry-run mode and inspect every planned path. Then, only
inside the exact target, materialize the foundation with both input documents,
run the Project Architect validator, and report the generated structure.

Do not overwrite different existing files.
Do not create or mutate a remote repository without separate authority.
Do not push, merge, deploy, access production, install dependencies, or start
product implementation.

Prepare the draft PROJECT_CONTEXT.md, ROADMAP.md, and first Global Stage proposal
from the approved inputs. Clearly mark generated architecture that still needs
owner acceptance.

Stop with:

FOUNDATION READY FOR OWNER REVIEW
```
