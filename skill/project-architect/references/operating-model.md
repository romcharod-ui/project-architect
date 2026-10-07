# Operating model

## Canonical project state

Keep one repository-tracked PROJECT_CONTEXT.md as the accepted status and
decision record. Chat history, task summaries, local notes, and stale branches
are evidence inputs, not competing sources of truth.

At the start of significant work, fetch the remote, verify the expected base,
read the complete canonical context, then read the assigned stage. Context
drift stops the task instead of being silently rebased or redesigned.

## Delivery hierarchy

- A Global Stage is an architecturally coherent, owner-approved outcome.
- Internal Checkpoints are implementation slices within that stage.
- One implementation writer owns a worktree.
- Auditors are independent and read-only.
- A Global Checkpoint produces an exact-HEAD branch, PR, CI, evidence, and
  handoff. It does not grant integration authority.
- Context integration records accepted reality after approval; it does not
  rewrite the candidate that reviewers inspected.

## Two independent routing axes

Do not confuse execution surface with model provider.

Execution surface / physical combine:
- Codex combine: the current ChatGPT/Codex application and native subagents.
- ZCode combine: the separate ZCode application and its native tasks/agents.

Model provider inside the Codex combine:
- OpenAI defaults GPT-6 Luna and GPT-6 Sol. GPT-6.1 Sol and GPT-6 Astra are
  manual owner CENTRAL selections, not automatic defaults.
- Authorized custom providers such as Z.AI, including GLM-5.3 and
  GLM-5.3-Flash.

Switching OpenAI <-> Z.AI models inside Codex does not require Git handoff.
Switching Codex <-> ZCode does.

## Role parity across models

Writer, auditor, and final-review permissions are defined by role, not by model.

A GLM auditor running as a native Codex subagent has the same read-only
permission contract as a Luna auditor. A GLM implementation worker has the same
workspace-write contract as the Luna implementation worker. Model/provider
selection must never secretly reduce or expand that role.

The generated Codex profiles include both OpenAI and Z.AI variants. The Z.AI
variants require a separately configured user-level zai_coding provider and
credentials; the repository does not store those secrets.

## Reviewer orchestration

Ordinary review uses the native subagent/reviewer mechanism of the current
physical combine. In Codex, use native subagents even when their model provider
is Z.AI.

Do not run a second nested Codex process merely to get a normal auditor. Use a
separate process-isolated read-only runner only when the stage explicitly
requires that stronger isolation.

Before a verdict:
1. complete the writer's current correction loop;
2. commit the candidate;
3. record exact Base, HEAD, branch, and merge-base;
4. give auditors those identities plus stage, changed paths, risks, and
   evidence locations.

If HEAD changes, the old verdict remains evidence for the old HEAD only.

Wait on already-created agents with the combine's event-driven wait/resume
primitive. Do not create periodic automations, recurring timers, or duplicate
agents just because output is delayed.

## Ambiguous outcomes

A timeout does not prove that a task failed or its writer stopped. Inspect the original task/session, worktree, processes, and latest commit before retrying. Resume the same task when safe; never spawn a duplicate writer or replay a one-time command without checking its receipt. If status remains unknown, stop at the last verified Git state and report it.

## Multi-combine execution

Codex and ZCode are equal physical combines. The owner chooses the active
combine for each checkpoint.

One checkpoint belongs to one physical combine. Switch only at a durable Git
boundary: committed and pushed state, current canonical context, known SHA, and
a clean working tree. The receiving combine fetches/pulls, verifies that
boundary, re-reads canonical context, and maps the provider-neutral roles to its
own native mechanisms.

A model-provider change inside Codex is not a combine switch and does not need a
handoff file.

Project Architect materializes a provider-neutral combine-handoff skill and
TOOL_HANDOFF_POLICY.md for physical combine changes.

## Git safety

- Keep the default branch immutable to ordinary implementation tasks.
- Require an exact expected base and clean worktree.
- Avoid rewriting published candidate history.
- Bind reviews and CI to the exact candidate commit.
- Preserve unrelated decisions and files.
- Require explicit authority for remote creation, push, merge, release, deploy,
  production access, or destructive recovery.

## Decision discipline

Record decisions that constrain later work. IDs are globally unique within the
project. A replacement marks the prior decision superseded and receives a new
ID; it does not erase history.

Do not turn ordinary implementation details into permanent decisions. Keep the
context compact enough to be read completely at every significant start gate.
