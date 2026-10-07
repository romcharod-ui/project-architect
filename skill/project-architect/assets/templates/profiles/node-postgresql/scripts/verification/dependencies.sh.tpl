#!/usr/bin/env bash
set -euo pipefail

umask 077
repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
cd -- "${repository_root}"

[[ -f package.json && -f package-lock.json ]] || {
  printf '%s\n' 'NPM_DEPENDENCIES INVALID reason=missing-manifest' >&2
  exit 1
}

package_blob="$(GIT_NO_REPLACE_OBJECTS=1 GIT_OPTIONAL_LOCKS=0 git hash-object package.json)"
lock_blob="$(GIT_NO_REPLACE_OBJECTS=1 GIT_OPTIONAL_LOCKS=0 git hash-object package-lock.json)"
node_version="$(node --version)"
identity="project-architect-npm-topology.v1 ${package_blob} ${lock_blob} ${node_version}"
marker="${repository_root}/node_modules/.project-architect-topology-v1"

case "${1:-verify}" in
  verify)
    [[ -d node_modules && ! -L node_modules ]] || {
      printf '%s\n' 'NPM_DEPENDENCIES INVALID action=install-once' >&2
      exit 1
    }
    npm ls --all --offline --ignore-scripts >/dev/null || {
      printf '%s\n' 'NPM_DEPENDENCIES INVALID action=install-once' >&2
      exit 1
    }
    temporary_marker="${marker}.$$"
    printf '%s\n' "${identity}" > "${temporary_marker}"
    mv -- "${temporary_marker}" "${marker}"
    printf 'NPM_DEPENDENCIES VERIFIED package=%s lock=%s node=%s\n' \
      "${package_blob}" "${lock_blob}" "${node_version}"
    ;;
  install)
    npm ci --cache "${NPM_CONFIG_CACHE:-${HOME}/.npm}"
    rm -f -- "${marker}"
    exec "$0" verify
    ;;
  *)
    printf '%s\n' 'usage: dependencies.sh [verify|install]' >&2
    exit 2
    ;;
esac
