# Getting started

This guide uses a fictional project, **Example Catalog**. Replace names and paths with your own. Keep credentials outside the repository.

## 1. Pick a pinned version

Clone this repository or download a release. Record its tag or commit SHA and use the same version for the conversation, skill, and bootstrap scripts. Use Python 3.11+ and Git. The first run works without ZCode, Tela, Cortex, or a custom model provider.

## 2. Agree on the project

For a new project, read `CHAT_START.md` in a coordinating conversation. It tells the assistant to read four companion files from the same pinned revision, summarize accepted decisions, ask only material questions, and prepare:

- `PROJECT_BRIEF.md`: users, outcome, accepted behavior, scope, data, and constraints.
- `FOUNDATION_PLAN.md`: stages, project profile, checks, role boundaries, and deferred decisions.
- An exact bootstrap prompt pointing to those documents and this pinned revision.

Review and approve these inputs before bootstrap. You can write them yourself using `chat/templates/`. Do not copy private conversations, API keys, or production data into them.

## 3. Install the skill

Copy the entire `skill/project-architect` directory into the skills directory for the Codex profile that will run bootstrap. Follow that product's current skill installation instructions for your platform. Codex on Windows and WSL can use separate profiles; installation in one does not imply installation in the other. Confirm that the skill appears, then invoke `project-architect` with the approved brief, plan, and target path.

The repository also supports running the bundled scripts directly, without skill installation.

## 4. Preview and generate

From the pinned repository checkout, with paths you control:

```sh
python3 skill/project-architect/scripts/bootstrap_project.py \
  --target /path/to/example-catalog \
  --brief /path/to/PROJECT_BRIEF.md \
  --foundation-plan /path/to/FOUNDATION_PLAN.md \
  --project-name "Example Catalog" \
  --profile generic \
  --dry-run
```

Inspect every proposed path and reconcile existing files. Repeat the command without `--dry-run` when the target is correct. The script refuses to overwrite files whose content differs.

```sh
python3 skill/project-architect/scripts/validate_project.py \
  --target /path/to/example-catalog
python3 /path/to/example-catalog/scripts/validate-model-routing.py \
  --root /path/to/example-catalog
```

The default `generic` profile records policy; define actual application checks before implementation. The optional `node-postgresql` profile adds stack-specific verification files. Validation checks generated repository bindings, not the model an agent actually ran.

## 5. Review the first stage

Inspect `PROJECT_CONTEXT.md`, `ROADMAP.md`, the proposed stage, and `docs/ORCHESTRATOR_PROTOCOL.md`. Accept or correct the generated technical choices. Then authorize the first implementation stage separately. Keep one writer per worktree; freeze a commit before independent review. A green CI run or reviewer PASS applies to its exact HEAD, not to later edits.

## 6. Use a second combine only when needed

Codex can route to a configured OpenAI or custom model provider within the same combine. Configure any custom provider and its secret at the user level; the repository supplies no key. ZCode is a separate application: set up its native user profiles on its host and check their actual role/model permissions. When switching between applications, use the generated `skills/combine-handoff/SKILL.md` at a committed, pushed, clean Git boundary. Verify the incoming SHA before resuming. Never assume a timeout means the prior writer stopped; inspect the task and worktree before retrying.

Usage limits are service specific. Switch at a checkpoint to preserve context and choose work deliberately; the handoff does not transfer quota. Tela and Cortex are optional, disabled by default. If enabled, use per-project identifiers, data minimization, and the generated context services policy.

## 7. Diagnose and contribute

If bootstrap reports a conflicting file, inspect the diff and reconcile it explicitly; do not force an overwrite. If a test or review fails, retain the actual output and exact commit identity, apply a bounded correction, then review the new HEAD. If a log was lost, say so rather than citing it.

Use [Issues](../.github/ISSUE_TEMPLATE/) for reproducible bugs and specific improvements, Discussions for open questions and ideas once enabled on the public repository, and Pull Requests for proposed changes. Include version, OS, application, exact command, expected and actual outcome, and redacted evidence. Never paste credentials or private project content.
