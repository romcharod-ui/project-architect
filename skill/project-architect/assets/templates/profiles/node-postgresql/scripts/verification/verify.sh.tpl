#!/usr/bin/env bash
set -euo pipefail

umask 077
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd -- "${script_dir}/../.." && pwd -P)"
cd -- "${repository_root}"

export CI=1
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-${HOME}/.npm}"
export NPM_CONFIG_USERCONFIG=/dev/null

has_npm_script() {
  node -e 'const p=require("./package.json"); process.exit(p.scripts?.[process.argv[1]] ? 0 : 1)' "$1"
}

dependencies() {
  "${script_dir}/dependencies.sh" verify
}

check() {
  dependencies
  has_npm_script check || {
    printf '%s\n' 'VERIFY REJECTED reason=missing-npm-check' >&2
    exit 1
  }
  npm run check
}

db() {
  dependencies
  has_npm_script test:db || {
    printf '%s\n' 'VERIFY REJECTED reason=missing-test-db' >&2
    exit 1
  }
  npm run test:db
}

audit_production() {
  dependencies
  npm audit --omit=dev
}

audit_full() {
  dependencies
  npm audit
}

case "${1:-help}" in
  check) check ;;
  db) db ;;
  audit-production) audit_production ;;
  audit-full) audit_full ;;
  final)
    check
    if has_npm_script test:db; then db; fi
    audit_production
    audit_full
    ;;
  *)
    printf '%s\n' 'usage: verify.sh {check|db|audit-production|audit-full|final}' >&2
    exit 2
    ;;
esac
