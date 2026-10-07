# Node.js + PostgreSQL verification profile

This profile supplements `LOCAL_VERIFICATION.md`.

## Dependencies

`scripts/verification/dependencies.sh verify` validates the installed npm
topology offline against `package.json` and `package-lock.json`. A marker is a
diagnostic identity record, not integrity proof. Run `install` once only when
the topology is invalid or a clean-install acceptance criterion requires it.

The npm download cache is persistent and user-owned. It is never removed by
ordinary verification or runtime cleanup.

## PostgreSQL

Before the first database stage choose and document one supported source:

1. a managed system PostgreSQL;
2. a pinned container image with persistent image layers; or
3. a user-owned checksum-pinned extracted toolchain cache.

Do not repeatedly download PostgreSQL into a disposable directory. If an
extracted cache is used, pin OS/architecture, exact version, source URLs and
SHA-256; validate archives and payload before execution; serialize builders;
publish atomically; and preserve verified archives/payload between runs.

Database clusters, sockets, PID files, transient credentials, and per-run roots
remain disposable even when the binaries are cached.

## Commands

Adapt `scripts/verification/verify.sh` only after confirming package scripts.
The default expects:

- `npm run check` as the aggregate application proof;
- optional `npm run test:db` as the complete database proof;
- `npm audit --omit=dev` and `npm audit` once at the final candidate.

Do not make a missing database command silently pass after the project declares
database testing mandatory.
