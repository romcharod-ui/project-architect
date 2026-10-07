# Verification and cache policy

## Separate durable inputs from disposable runtime

Preserve when validated:

- package-manager download caches;
- installed dependency trees that pass the package manager's offline topology
  check against current manifests;
- checksum-pinned tool archives;
- validated extracted toolchains;
- compiler and build caches whose keys include relevant inputs.

Remove after each run only when created for that run:

- isolated temporary databases and clusters;
- sockets, PID files, transient credentials, and ports/listeners;
- per-run work directories;
- unredacted logs containing sensitive values;
- state owned only by the current verification process.

Never delete a reusable cache merely to prove cleanup.

## Environment lifecycle

Identify the owner and data boundary of each test environment before running checks. After the tests, shut down task-owned virtual machines and container runtimes (for example, Lima or Colima) when no active task or owner-facing preview needs them, so they do not continue consuming host RAM. Check ownership and active dependencies before stopping anything; never stop a shared environment used by other work. Stop and remove only isolated per-run resources after capturing redacted evidence. Preserve an owner-facing preview and its data until explicitly authorized to retire it. A stopped persistent test environment may be reused after checking configuration and data freshness. Never delete shared containers, databases, or volumes by a broad name or prefix. Report which virtual machines and environments remain running or stopped and why.

## Efficient test topology

During implementation run focused tests for the affected behavior. At the
final clean exact candidate run one aggregate application check, one full
database/integration suite when applicable, and dependency/security audits once.
Do not separately repeat every subcommand already included in the aggregate.

Reinstall dependencies only when manifests changed, the installed topology is
invalid, or a clean-install acceptance criterion explicitly requires it.
Persistent caches improve speed but do not replace topology or checksum
verification.

## Toolchain adapters

The generic profile records policy only. A technology profile may implement a
toolchain cache when it can pin platform, version, source URLs, and checksums;
validate before execution; serialize builders; publish atomically; and reject
partial or modified caches.

Do not copy an OS-specific toolchain downloader into an incompatible project.
Detect the execution environment and create a reviewed adapter or use an
already managed system/container toolchain.

## Evidence

Evidence describes work that actually happened: exact command, exit code, candidate SHA, and a real redacted-log path and checksum if retained. If a script failed before writing a log, say so. Never cite a missing file. Verify user-facing behavior in the target UI when available; screenshots and unit tests alone do not prove interaction. A changed HEAD requires new verdicts.

Reusable evidence binds the exact commit/tree, command identity, relevant
manifests, tool versions, clean state, result, redacted-log digest, and cleanup
result. Local evidence complements rather than replaces independent CI and
reviewer judgment.
