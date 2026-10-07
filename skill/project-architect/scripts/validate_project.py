#!/usr/bin/env python3
"""Validate the generated foundation's structural invariants."""

from __future__ import annotations

import argparse
import json
import re
import stat
import subprocess
import sys
from pathlib import Path

PROJECT_KEY = re.compile(r"[a-z][a-z0-9-]{1,63}\Z")
TRUSTED_ROUTING_CHECKER = (
    Path(__file__).resolve().parents[1]
    / "assets/templates/core/scripts/validate-model-routing.py.tpl"
)

CORE_FILES = (
    "AGENTS.md",
    "PROJECT_CONTEXT.md",
    "ROADMAP.md",
    ".codex/config.toml",
    ".codex/project-foundation.json",
    ".codex/context-services.json",
    ".codex/agents/implementation_worker.toml",
    ".codex/agents/luna_auditor.toml",
    ".codex/agents/auditor.toml",
    ".codex/agents/security_reviewer.toml",
    ".codex/agents/test_reviewer.toml",
    ".codex/agents/maintainability_reviewer.toml",
    ".codex/agents/web_researcher.toml",
    ".codex/agents/final_judge.toml",
    ".codex/agents/glm_implementation_worker.toml",
    ".codex/agents/glm_flash_implementation_worker.toml",
    ".codex/agents/glm_auditor.toml",
    ".codex/agents/glm_flash_auditor.toml",
    ".codex/agents/glm_final_judge.toml",
    "docs/product/PROJECT_BRIEF.md",
    "docs/codex/MODEL_ROUTING.md",
    "docs/codex/ZCODE_NATIVE_PROFILES.md",
    "scripts/validate-model-routing.py",
    ".github/workflows/model-routing.yml",
    "docs/codex/LOCAL_VERIFICATION.md",
    "docs/codex/CENTRAL_HANDOFF.md",
    "docs/TOOL_HANDOFF_POLICY.md",
    "docs/CONTEXT_SERVICES_POLICY.md",
    "docs/ORCHESTRATOR_PROTOCOL.md",
    "docs/handoffs/LATEST.md",
    "skills/combine-handoff/SKILL.md",
    "skills/combine-handoff/templates/handoff.md",
    "docs/stages/STAGE_TEMPLATE.md",
)

def regular(path: Path) -> bool:
    try:
        return stat.S_ISREG(path.lstat().st_mode) and not path.is_symlink()
    except FileNotFoundError:
        return False

def require_markers(path: Path, markers: tuple[str, ...], problems: list[str], label: str) -> None:
    if not regular(path):
        return
    text = path.read_text(encoding="utf-8")
    for marker in markers:
        if marker not in text:
            problems.append(f"{label}:{path.name}:{marker}")

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True)
    args = parser.parse_args()
    target = Path(args.target).expanduser().resolve()
    problems: list[str] = []

    for name in CORE_FILES:
        path = target / name
        if not regular(path):
            problems.append(f"missing-or-unsafe:{name}")
            continue
        if path.stat().st_size == 0:
            problems.append(f"empty:{name}")
        if path.suffix in {".md", ".toml", ".json"}:
            try:
                text = path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                problems.append(f"not-utf8:{name}")
                continue
            if any(token in text for token in ("{{PROJECT_NAME}}", "{{PROFILE}}", "{{DATE}}")):
                problems.append(f"unrendered-template:{name}")

    manifest_path = target / ".codex/project-foundation.json"
    if regular(manifest_path):
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            if manifest.get("format") != "project-architect-bootstrap/v1":
                problems.append("invalid-foundation-manifest")
            if manifest.get("foundation_version") != "0.6.0":
                problems.append("unexpected-foundation-version")
            if manifest.get("coordinated_foundation_plan") is True and not regular(
                target / "docs/product/FOUNDATION_PLAN.md"
            ):
                problems.append("missing-foundation-plan")
        except (UnicodeDecodeError, json.JSONDecodeError):
            problems.append("invalid-foundation-manifest")

    context_path = target / ".codex/context-services.json"
    if regular(context_path):
        try:
            context = json.loads(context_path.read_text(encoding="utf-8"))
            if set(context) != {"format", "project_key", "native_indexing", "tela", "cortex"}:
                problems.append("invalid-context-services-shape")
            if context.get("format") != "project-architect-context-services/v1":
                problems.append("invalid-context-services-format")
            if context.get("native_indexing") != "preferred":
                problems.append("invalid-native-indexing-policy")
            key = context.get("project_key")
            if key is not None and (not isinstance(key, str) or not PROJECT_KEY.fullmatch(key)):
                problems.append("invalid-context-project-key")
            tela = context.get("tela")
            cortex = context.get("cortex")
            if not isinstance(tela, dict) or set(tela) != {"enabled", "space"}:
                problems.append("invalid-tela-context-config")
            else:
                if not isinstance(tela.get("enabled"), bool):
                    problems.append("invalid-tela-enabled")
                if tela.get("enabled"):
                    if key is None or not isinstance(tela.get("space"), str) or not tela.get("space"):
                        problems.append("invalid-tela-opt-in")
                elif tela.get("space") is not None:
                    problems.append("disabled-tela-must-not-have-space")
            if not isinstance(cortex, dict) or set(cortex) != {"enabled", "namespace"}:
                problems.append("invalid-cortex-context-config")
            else:
                if not isinstance(cortex.get("enabled"), bool):
                    problems.append("invalid-cortex-enabled")
                if cortex.get("enabled"):
                    if key is None or cortex.get("namespace") != f"project:{key}":
                        problems.append("invalid-cortex-opt-in")
                elif cortex.get("namespace") is not None:
                    problems.append("disabled-cortex-must-not-have-namespace")
        except (UnicodeDecodeError, json.JSONDecodeError):
            problems.append("invalid-context-services-json")

    expected_agents = {
        "implementation_worker.toml": (
            'model = "gpt-6-luna"',
            'model_reasoning_effort = "high"',
            'sandbox_mode = "workspace-write"',
            'approval_policy = "on-request"',
        ),
        "luna_auditor.toml": (
            'model = "gpt-6-luna"',
            'model_reasoning_effort = "high"',
            'sandbox_mode = "read-only"',
            'approval_policy = "never"',
        ),
        "web_researcher.toml": (
            'model = "gpt-6-luna"',
            'model_reasoning_effort = "low"',
            'sandbox_mode = "read-only"',
        ),
        "final_judge.toml": (
            'model = "gpt-6-sol"',
            'model_reasoning_effort = "high"',
            'sandbox_mode = "read-only"',
            'approval_policy = "never"',
        ),
        "glm_implementation_worker.toml": (
            'model_provider = "zai_coding"',
            'model = "glm-5.3"',
            'model_reasoning_effort = "max"',
            'sandbox_mode = "workspace-write"',
            'approval_policy = "on-request"',
        ),
        "glm_flash_implementation_worker.toml": (
            'model_provider = "zai_coding"',
            'model = "glm-5.3-flash"',
            'model_reasoning_effort = "max"',
            'sandbox_mode = "workspace-write"',
            'approval_policy = "on-request"',
        ),
        "glm_auditor.toml": (
            'model_provider = "zai_coding"',
            'model = "glm-5.3"',
            'model_reasoning_effort = "max"',
            'sandbox_mode = "read-only"',
            'approval_policy = "never"',
        ),
        "glm_flash_auditor.toml": (
            'model_provider = "zai_coding"',
            'model = "glm-5.3-flash"',
            'model_reasoning_effort = "max"',
            'sandbox_mode = "read-only"',
            'approval_policy = "never"',
        ),
        "glm_final_judge.toml": (
            'model_provider = "zai_coding"',
            'model = "glm-5.3"',
            'model_reasoning_effort = "max"',
            'sandbox_mode = "read-only"',
            'approval_policy = "never"',
        ),
    }
    agents_dir = target / ".codex/agents"
    for filename in (
        "auditor.toml", "security_reviewer.toml", "test_reviewer.toml",
        "maintainability_reviewer.toml",
    ):
        expected_agents[filename] = (
            'model = "gpt-6-luna"',
            'model_reasoning_effort = "high"',
            'sandbox_mode = "read-only"',
            'approval_policy = "never"',
        )
    for filename, markers in expected_agents.items():
        require_markers(agents_dir / filename, markers, problems, "agent-binding")

    # Auditor permission parity: model/provider may differ; authority must not.
    auditor_files = (
        "luna_auditor.toml", "auditor.toml", "security_reviewer.toml",
        "test_reviewer.toml", "maintainability_reviewer.toml",
        "glm_auditor.toml", "glm_flash_auditor.toml",
    )
    for filename in auditor_files:
        require_markers(
            agents_dir / filename,
            ('sandbox_mode = "read-only"', 'approval_policy = "never"'),
            problems,
            "auditor-parity",
        )

    routing = target / "docs/codex/MODEL_ROUTING.md"
    require_markers(
        routing,
        (
            "two different axes",
            "same sandbox and approval",
            "model_provider",
            "zai_coding",
            "does not trigger",
            "ZCode physical combine",
            "nested codex exec",
            "event-driven",
            "GPT-6 Luna",
            "GPT-6 Sol",
            "native ZCode profiles",
        ),
        problems,
        "model-routing",
    )

    agents_contract = target / "AGENTS.md"
    require_markers(
        agents_contract,
        (
            "Two routing axes",
            "glm_flash_auditor",
            "same sandbox and approval permissions",
            "No combine-handoff is needed",
            "nested codex exec",
            "event-driven",
            "GPT-6 Luna",
            "GPT-6 Sol",
        ),
        problems,
        "agents-contract",
    )

    policy = target / "docs/TOOL_HANDOFF_POLICY.md"
    require_markers(
        policy,
        (
            "Model-provider changes inside Codex are not combine changes",
            "Codex and ZCode",
            "OpenAI and Z.AI models may be mixed across roles",
            "прими работу",
            "native orchestrator",
            "full orchestrated combine",
        ),
        problems,
        "handoff-policy",
    )

    handoff = target / "skills/combine-handoff/SKILL.md"
    require_markers(
        handoff,
        (
            "physical execution combine",
            "Do not use this skill for a model-provider switch inside Codex",
            "Provider-neutral roles cross the boundary",
            "прими работу",
            "перехожу на ZCode",
            "native orchestrator",
        ),
        problems,
        "combine-handoff",
    )

    context_policy = target / "docs/CONTEXT_SERVICES_POLICY.md"
    require_markers(
        context_policy,
        (
            "Git is the authoritative project state",
            "Native project indexing",
            "Tela is an optional semantic",
            "Cortex is an optional curated",
            "Context-service failure is non-blocking",
            "If Git and an auxiliary service disagree",
            "Do not upload secrets",
            "Direct Tela/Cortex access is not a default",
        ),
        problems,
        "context-services-policy",
    )

    orchestrator = target / "docs/ORCHESTRATOR_PROTOCOL.md"
    require_markers(
        orchestrator,
        (
            "ZCode uses native GLM orchestration",
            "full orchestrated combine",
            "one writer",
            "independent read-only auditor(s)",
            "Final reviewer",
            "event-driven",
            "прими работу",
        ),
        problems,
        "orchestrator-protocol",
    )

    routing_checker = target / "scripts/validate-model-routing.py"
    if regular(routing_checker):
        if routing_checker.read_bytes() != TRUSTED_ROUTING_CHECKER.read_bytes():
            problems.append("model-routing-checker-drift")
        result = subprocess.run(
            [sys.executable, str(TRUSTED_ROUTING_CHECKER), "--root", str(target)],
            capture_output=True, text=True, check=False,
        )
        if result.returncode != 0:
            problems.append("model-routing-check:" + (result.stderr.strip() or result.stdout.strip()))

    if problems:
        for problem in problems:
            print(f"FOUNDATION INVALID {problem}", file=sys.stderr)
        return 1
    print(f"FOUNDATION VALID files={len(CORE_FILES)} target={target}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
