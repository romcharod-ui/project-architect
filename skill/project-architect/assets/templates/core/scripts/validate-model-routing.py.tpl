#!/usr/bin/env python3
"""Check static route bindings; actual agent use still needs runtime evidence."""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
# name: provider, model, effort, sandbox, approval
CODEX = {
    "implementation_worker": (None, "gpt-6-luna", "high", "workspace-write", "on-request"),
    "luna_auditor": (None, "gpt-6-luna", "high", "read-only", "never"),
    "auditor": (None, "gpt-6-luna", "high", "read-only", "never"),
    "security_reviewer": (None, "gpt-6-luna", "high", "read-only", "never"),
    "test_reviewer": (None, "gpt-6-luna", "high", "read-only", "never"),
    "maintainability_reviewer": (None, "gpt-6-luna", "high", "read-only", "never"),
    "web_researcher": (None, "gpt-6-luna", "low", "read-only", "never"),
    "final_judge": (None, "gpt-6-sol", "high", "read-only", "never"),
    "glm_implementation_worker": ("zai_coding", "glm-5.3", "max", "workspace-write", "on-request"),
    "glm_flash_implementation_worker": ("zai_coding", "glm-5.3-flash", "max", "workspace-write", "on-request"),
    "glm_auditor": ("zai_coding", "glm-5.3", "max", "read-only", "never"),
    "glm_flash_auditor": ("zai_coding", "glm-5.3-flash", "max", "read-only", "never"),
    "glm_final_judge": ("zai_coding", "glm-5.3", "max", "read-only", "never"),
}
MATRIX = (
    "| coordinator / architect | GPT-6 Sol / high | GLM-5.3 / max |",
    "| implementation writer | GPT-6 Luna / high | GLM-5.3-Flash / max |",
    "| correctness auditor | GPT-6 Luna / high | GLM-5.3-Flash / max |",
    "| security/privacy reviewer | GPT-6 Luna / high | GLM-5.3-Flash / max |",
    "| tests/evidence reviewer | GPT-6 Luna / high | GLM-5.3-Flash / max |",
    "| maintainability reviewer | GPT-6 Luna / high | GLM-5.3-Flash / max |",
    "| researcher | GPT-6 Luna / low | GLM-5.3-Flash / max |",
    "| final judge | GPT-6 Sol / high | GLM-5.3 / max |",
)
ZCODE = {
    "writer": ("GLM-5.3-Flash", None),
    "auditor": ("GLM-5.3-Flash", ("Read", "Grep", "Glob")),
    "security-reviewer": ("GLM-5.3-Flash", ("Read", "Grep", "Glob")),
    "test-reviewer": ("GLM-5.3-Flash", ("Read", "Grep", "Glob")),
    "final-judge": ("GLM-5.3", ("Read", "Grep", "Glob")),
}


def compare(actual: object, expected: object, label: str, errors: list[str]) -> None:
    if actual != expected:
        errors.append(f"{label}: expected {expected!r}, got {actual!r}")


def repo(root: Path) -> list[str]:
    errors: list[str] = []
    for name, contract in CODEX.items():
        path = root / ".codex/agents" / f"{name}.toml"
        if path.is_symlink() or not path.is_file():
            errors.append(f"missing or unsafe Codex profile: {name}")
            continue
        try:
            with path.open("rb") as stream:
                data = tomllib.load(stream)
        except (OSError, ValueError, tomllib.TOMLDecodeError) as exc:
            errors.append(f"invalid Codex profile {name}: {type(exc).__name__}")
            continue
        provider, model, effort, sandbox, approval = contract
        compare(data.get("name"), name, f"{name}.name", errors)
        if provider is None:
            if "model_provider" in data:
                errors.append(f"{name}: unexpected model_provider")
        else:
            compare(data.get("model_provider"), provider, f"{name}.model_provider", errors)
        for key, expected in (("model", model), ("model_reasoning_effort", effort),
                              ("sandbox_mode", sandbox), ("approval_policy", approval)):
            compare(data.get(key), expected, f"{name}.{key}", errors)
    for filename, markers in {
        "AGENTS.md": MATRIX,
        "docs/codex/MODEL_ROUTING.md": ("GPT-6 Luna", "GPT-6 Sol", "GLM-5.3-Flash",
                                          "native ZCode profiles", "runtime provider/model evidence"),
    }.items():
        path = root / filename
        if path.is_symlink() or not path.is_file():
            errors.append(f"missing or unsafe routing document: {filename}")
            continue
        text = path.read_text(encoding="utf-8")
        for marker in markers:
            if marker not in text:
                errors.append(f"{filename}: missing routing contract {marker!r}")
    return errors


def frontmatter(path: Path) -> tuple[dict[str, str], tuple[str, ...] | None]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        return {}, None
    values: dict[str, str] = {}
    tools: list[str] | None = None
    in_tools = False
    for line in lines[1:]:
        if line == "---":
            break
        if line.startswith("tools:"):
            tools, in_tools = [], True
            continue
        if in_tools and line.startswith("  - "):
            assert tools is not None
            tools.append(line[4:].strip().strip("\"'"))
            continue
        in_tools = False
        if ":" in line and not line.startswith((" ", "\t")):
            key, value = line.split(":", 1)
            values[key.strip()] = value.strip().strip("\"'")
    return values, tuple(tools) if tools is not None else None


def local_zcode(directory: Path, prefix: str) -> list[str]:
    errors: list[str] = []
    if directory.is_symlink() or not directory.is_dir():
        return ["ZCode profile directory missing or unsafe"]
    for role, (model, tools_expected) in ZCODE.items():
        name = f"{prefix}-{role}"
        path = directory / f"{name}.md"
        if path.is_symlink() or not path.is_file():
            errors.append(f"missing or unsafe native ZCode profile: {name}")
            continue
        data, tools = frontmatter(path)
        compare(data.get("name"), name, f"{name}.name", errors)
        provider, sep, leaf = data.get("model", "").rpartition("/")
        if not sep or not (provider.startswith("account:zai-") or provider == "zai-standard-api"):
            errors.append(f"{name}: expected explicit Z.ai provider binding")
        compare(leaf, model, f"{name}.model", errors)
        compare(data.get("thoughtLevel"), "max", f"{name}.thoughtLevel", errors)
        compare(data.get("injectAgentsMd"), "true", f"{name}.injectAgentsMd", errors)
        compare(tools, tools_expected, f"{name}.tools", errors)
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--zcode-dir", type=Path)
    parser.add_argument("--zcode-prefix")
    args = parser.parse_args()
    if (args.zcode_dir is None) != (args.zcode_prefix is None):
        parser.error("--zcode-dir and --zcode-prefix must be supplied together")
    if args.zcode_prefix and not re.fullmatch(r"[a-z][a-z0-9-]{1,63}", args.zcode_prefix):
        parser.error("--zcode-prefix must be a lowercase project slug")
    errors = repo(args.root.resolve())
    scope = "repository"
    if args.zcode_dir is not None:
        errors.extend(local_zcode(args.zcode_dir, args.zcode_prefix))
        scope += "+local-zcode"
    if errors:
        print("MODEL_ROUTING_CHECK=FAIL", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"MODEL_ROUTING_CHECK=PASS scope={scope}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
