# Checkpoint protocol

## Global Stage

A Global Stage is an architecturally coherent owner-approved outcome. Its stage
file records exact Base, branch, goal, accepted behavior, write set, exclusions,
risks, checkpoints, verification, reviewers, recovery, and hard stop.

## Internal Checkpoint

An Internal Checkpoint is a bounded implementation slice within the accepted
stage. The Implementer may continue autonomously while architecture, scope,
authority, and risk remain unchanged.

## Audit/fix loop

Reviewers inspect the real candidate and remain read-only. The Implementer fixes
bounded findings and reruns affected checks. Stop after three unsuccessful
cycles or immediately on an authority/architecture fork.

## Ambiguous outcomes

A timeout does not prove that a task failed or its writer stopped. Inspect the original task/session, worktree, processes, and latest commit before retrying. Resume the same task when safe; never spawn a duplicate writer or replay a one-time command without checking its receipt. If status remains unknown, stop at the last verified Git state and report it.

Evidence describes work that actually happened: exact command, exit code, candidate SHA, and a real redacted-log path and checksum if retained. If a script failed before writing a log, say so. Never cite a missing file. Verify user-facing behavior in the target UI when available; screenshots and unit tests alone do not prove interaction. A changed HEAD requires new verdicts.

## Global Checkpoint

Produce an exact candidate commit, branch, PR, exact-HEAD CI, clean worktree,
review verdicts, recovery path, and CENTRAL handoff. This evidence does not
authorize merge or default-branch mutation.
