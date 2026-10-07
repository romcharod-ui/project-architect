# Local verification — {{PROJECT_NAME}}

## Policy

Preserve validated reusable inputs:

- dependency-manager download caches;
- installed dependency topology that validates against current manifests;
- checksum-pinned tool archives and extracted toolchains;
- correctly keyed compiler/build caches.

Delete per-run state:

- isolated databases and clusters created for this run;
- sockets, PID files, credentials, listeners, and processes;
- temporary roots created by the current run;
- unsafe or unredacted diagnostic output.

Never call cache deletion “cleanup”. A project profile must document cache
identity, validation, ownership, location, and rebuild behavior.

## Environment lifecycle

Identify the owner and data boundary of each test environment before running checks. After the tests, shut down task-owned virtual machines and container runtimes (for example, Lima or Colima) when no active task or owner-facing preview needs them, so they do not continue consuming host RAM. Check ownership and active dependencies before stopping anything; never stop a shared environment used by other work. Stop and remove only isolated per-run resources after capturing redacted evidence. Preserve an owner-facing preview and its data until explicitly authorized to retire it. A stopped persistent test environment may be reused after checking configuration and data freshness. Never delete shared containers, databases, or volumes by a broad name or prefix. Report which virtual machines and environments remain running or stopped and why.

## Test topology

- During development: focused tests for changed behavior.
- Final clean candidate: one aggregate application proof.
- Full database/integration proof: once, when applicable.
- Dependency/security audits: once per final candidate.
- Independent exact-HEAD CI: required.

Before review, run `python3 scripts/validate-model-routing.py` and retain its
exit code for the frozen candidate. The generated GitHub routing workflow
checks the exact PR head independently. This static check proves repository
bindings, not which model an agent actually used. At each checkpoint capture
sanitized runtime provider/model/effort/status for each material agent and
reject a review lane whose route differs from the approved matrix. Do not
store request bodies, credentials, or raw model-I/O logs. On a ZCode host,
validate native user profiles separately with the checker's `--zcode-dir` and
`--zcode-prefix` options; repository CI cannot inspect them.

Evidence describes work that actually happened: exact command, exit code, candidate SHA, and a real redacted-log path and checksum if retained. If a script failed before writing a log, say so. Never cite a missing file. Verify user-facing behavior in the target UI when available; screenshots and unit tests alone do not prove interaction. A changed HEAD requires new verdicts.

Do not reinstall unchanged valid dependencies. Do not run subcommands
individually and then repeat them through the aggregate command.

## Profile status

Foundation profile: `{{PROFILE}}`.

Before the first implementation stage, record exact commands, supported
platforms, cache roots, tool versions, cleanup boundaries, and redaction rules.
Profile-specific documentation may extend but not weaken this policy.
