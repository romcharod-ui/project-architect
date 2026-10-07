#!/usr/bin/env python3
"""Safely materialize a Project Architect foundation without overwrites."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import shutil
import stat
import sys
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parent.parent
TEMPLATES = SKILL_ROOT / "assets" / "templates"
MAX_BRIEF_BYTES = 1_000_000
TEXT_SUFFIX = ".tpl"
PROJECT_KEY = re.compile(r"[a-z][a-z0-9-]{1,63}\Z")
TELA_SPACE = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]{0,127}\Z")


def fail(message: str) -> "None":
    raise SystemExit(f"BOOTSTRAP REJECTED: {message}")


def regular_file(path: Path) -> bool:
    try:
        mode = path.lstat().st_mode
    except FileNotFoundError:
        return False
    return stat.S_ISREG(mode) and not path.is_symlink()


def safe_target(raw: str) -> Path:
    supplied = Path(raw).expanduser().absolute()
    if supplied.is_symlink():
        fail("target must not be a symlink")
    path = supplied.resolve()
    if path == Path(path.anchor) or path == Path.home().resolve():
        fail("target must not be a filesystem or home root")
    if path.exists() and (not path.is_dir() or path.is_symlink()):
        fail("target must be a real directory")
    return path


def safe_parent(target: Path, destination: Path) -> None:
    try:
        relative = destination.relative_to(target)
    except ValueError:
        fail(f"output escapes target: {destination}")
    current = target
    for part in relative.parts[:-1]:
        current = current / part
        if current.is_symlink():
            fail(f"output parent must not be a symlink: {current}")
        if current.exists() and not current.is_dir():
            fail(f"output parent must be a directory: {current}")


def source_files(root: Path) -> list[Path]:
    if not root.is_dir() or root.is_symlink():
        fail(f"template root is unavailable: {root}")
    files: list[Path] = []
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            fail(f"template symlink is forbidden: {path}")
        if path.is_file():
            files.append(path)
        elif not path.is_dir():
            fail(f"special template entry is forbidden: {path}")
    return files


def output_name(relative: Path) -> Path:
    name = relative.name
    if name.endswith(TEXT_SUFFIX):
        name = name[: -len(TEXT_SUFFIX)]
    return relative.with_name(name)


def rendered_bytes(source: Path, values: dict[str, str]) -> bytes:
    data = source.read_bytes()
    if source.name.endswith(TEXT_SUFFIX):
        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError:
            fail(f"text template is not UTF-8: {source}")
        for key, value in values.items():
            text = text.replace("{{" + key + "}}", value)
        data = text.encode("utf-8")
    return data


def collect(profile: str, values: dict[str, str]) -> dict[Path, bytes]:
    planned: dict[Path, bytes] = {}
    roots = [TEMPLATES / "core"]
    if profile != "generic":
        roots.append(TEMPLATES / "profiles" / profile)
    for root in roots:
        for source in source_files(root):
            relative = output_name(source.relative_to(root))
            data = rendered_bytes(source, values)
            previous = planned.get(relative)
            if previous is not None and previous != data:
                fail(f"profile conflicts with core template: {relative}")
            planned[relative] = data
    return planned


def input_bytes(path: Path, label: str) -> bytes:
    if not regular_file(path):
        fail(f"{label} must be a regular non-symlink file")
    if path.stat().st_size > MAX_BRIEF_BYTES:
        fail(f"{label} exceeds 1 MB")
    data = path.read_bytes()
    try:
        data.decode("utf-8")
    except UnicodeDecodeError:
        fail(f"{label} must be UTF-8 text")
    return data


def write_file(target: Path, path: Path, data: bytes, executable: bool) -> str:
    safe_parent(target, path)
    if path.exists() or path.is_symlink():
        if not regular_file(path):
            fail(f"existing output is not a regular file: {path}")
        if path.read_bytes() != data:
            fail(f"refusing to overwrite different file: {path}")
        return "unchanged"
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.project-architect-{os.getpid()}")
    if temporary.exists() or temporary.is_symlink():
        fail(f"temporary output already exists: {temporary}")
    temporary.write_bytes(data)
    temporary.chmod(0o755 if executable else 0o644)
    temporary.replace(path)
    return "created"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True)
    parser.add_argument("--brief", required=True)
    parser.add_argument("--foundation-plan")
    parser.add_argument("--project-name", required=True)
    parser.add_argument("--profile", choices=("generic", "node-postgresql"), default="generic")
    parser.add_argument("--project-key", help="stable project slug for context-service isolation")
    parser.add_argument("--tela-space", help="opt in to a dedicated Tela space")
    parser.add_argument("--cortex-namespace", help="opt in to project:<project-key> Cortex namespace")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    name = args.project_name.strip()
    if not name or len(name) > 120 or any(char in name for char in "\r\n\0"):
        fail("project name must contain 1-120 safe text characters")
    key = args.project_key
    if key is not None and not PROJECT_KEY.fullmatch(key):
        fail("project key must be a lowercase slug of 2-64 characters")
    if args.tela_space is not None and not TELA_SPACE.fullmatch(args.tela_space):
        fail("Tela space must be a dedicated simple identifier")
    if (args.tela_space or args.cortex_namespace) and key is None:
        fail("context-service opt-in requires --project-key")
    if args.cortex_namespace is not None and args.cortex_namespace != f"project:{key}":
        fail("Cortex namespace must equal project:<project-key>")
    target = safe_target(args.target)
    # Preserve the caller-supplied final path component for the lstat-based
    # non-symlink check in brief_bytes().
    brief = Path(args.brief).expanduser().absolute()
    foundation_plan = (
        Path(args.foundation_plan).expanduser().absolute()
        if args.foundation_plan is not None
        else None
    )
    values = {
        "PROJECT_NAME": name,
        "PROFILE": args.profile,
        "DATE": dt.datetime.now(dt.timezone.utc).date().isoformat(),
    }
    planned = collect(args.profile, values)
    planned[Path("docs/product/PROJECT_BRIEF.md")] = input_bytes(brief, "brief")
    if foundation_plan is not None:
        planned[Path("docs/product/FOUNDATION_PLAN.md")] = input_bytes(
            foundation_plan, "foundation plan"
        )
    manifest = {
        "format": "project-architect-bootstrap/v1",
        "foundation_version": "0.6.0",
        "coordinated_foundation_plan": foundation_plan is not None,
        "profile": args.profile,
        "project_name": name,
    }
    planned[Path(".codex/project-foundation.json")] = (
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    ).encode("utf-8")
    context_services = {
        "format": "project-architect-context-services/v1",
        "project_key": key,
        "native_indexing": "preferred",
        "tela": {"enabled": args.tela_space is not None, "space": args.tela_space},
        "cortex": {"enabled": args.cortex_namespace is not None,
                   "namespace": args.cortex_namespace},
    }
    planned[Path(".codex/context-services.json")] = (
        json.dumps(context_services, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    ).encode("utf-8")

    conflicts = []
    for relative, data in planned.items():
        destination = target / relative
        if destination.exists() or destination.is_symlink():
            if not regular_file(destination) or destination.read_bytes() != data:
                conflicts.append(str(relative))
    if conflicts:
        fail("different target files already exist: " + ", ".join(conflicts))

    if args.dry_run:
        for relative in sorted(planned):
            state = "unchanged" if (target / relative).exists() else "create"
            print(f"{state.upper()} {relative}")
        print(f"BOOTSTRAP DRY_RUN PASS files={len(planned)} profile={args.profile}")
        return 0

    target.mkdir(parents=True, exist_ok=True)
    created = unchanged = 0
    for relative, data in sorted(planned.items()):
        executable = relative.parts[:2] == ("scripts", "verification") and relative.suffix in {".sh", ".py"}
        result = write_file(target, target / relative, data, executable)
        created += result == "created"
        unchanged += result == "unchanged"
    print(
        f"BOOTSTRAP PASS files={len(planned)} created={created} "
        f"unchanged={unchanged} profile={args.profile}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
