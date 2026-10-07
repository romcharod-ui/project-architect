from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skill" / "project-architect"
BOOTSTRAP = SKILL / "scripts" / "bootstrap_project.py"
VALIDATE = SKILL / "scripts" / "validate_project.py"


class BootstrapTests(unittest.TestCase):
    def invoke(self, script: Path, *args: str, expect: int = 0) -> subprocess.CompletedProcess[str]:
        completed = subprocess.run(
            [sys.executable, str(script), *args],
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(completed.returncode, expect, completed.stdout + completed.stderr)
        return completed

    def test_generic_dry_run_and_materialization(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            plan = root / "plan.md"
            target = root / "project"
            brief.write_text("# Product brief\n\nAccepted scope.\n", encoding="utf-8")
            plan.write_text("# Foundation plan\n\nApproved profile.\n", encoding="utf-8")
            common = (
                "--target", str(target), "--brief", str(brief),
                "--foundation-plan", str(plan),
                "--project-name", "Example", "--profile", "generic",
            )
            dry = self.invoke(BOOTSTRAP, *common, "--dry-run")
            self.assertIn("BOOTSTRAP DRY_RUN PASS", dry.stdout)
            self.assertFalse(target.exists())
            self.invoke(BOOTSTRAP, *common)
            self.invoke(VALIDATE, "--target", str(target))
            self.invoke(target / "scripts/validate-model-routing.py", "--root", str(target))
            self.assertIn("Example", (target / "PROJECT_CONTEXT.md").read_text(encoding="utf-8"))
            self.assertTrue((target / "skills/combine-handoff/SKILL.md").is_file())
            self.assertTrue((target / "docs/TOOL_HANDOFF_POLICY.md").is_file())
            self.assertIn("No active handoff yet", (target / "docs/handoffs/LATEST.md").read_text(encoding="utf-8"))
            self.assertEqual(
                (target / "docs/product/FOUNDATION_PLAN.md").read_text(encoding="utf-8"),
                plan.read_text(encoding="utf-8"),
            )
            context = json.loads(
                (target / ".codex/context-services.json").read_text(encoding="utf-8")
            )
            self.assertEqual(context["native_indexing"], "preferred")
            self.assertIsNone(context["project_key"])
            self.assertEqual(context["tela"], {"enabled": False, "space": None})
            self.assertEqual(context["cortex"], {"enabled": False, "namespace": None})
            policy = (target / "docs/CONTEXT_SERVICES_POLICY.md").read_text(encoding="utf-8")
            self.assertIn("Git is the authoritative project state", policy)
            self.assertIn("Context-service failure is non-blocking", policy)

    def test_context_services_opt_in(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            target = root / "project"
            brief.write_text("# Brief\\n", encoding="utf-8")
            self.invoke(
                BOOTSTRAP,
                "--target", str(target), "--brief", str(brief),
                "--project-name", "Context", "--profile", "generic",
                "--project-key", "example-catalog",
                "--tela-space", "example-catalog",
                "--cortex-namespace", "project:example-catalog",
            )
            self.invoke(VALIDATE, "--target", str(target))
            context = json.loads(
                (target / ".codex/context-services.json").read_text(encoding="utf-8")
            )
            self.assertEqual(context["project_key"], "example-catalog")
            self.assertEqual(context["tela"], {"enabled": True, "space": "example-catalog"})
            self.assertEqual(
                context["cortex"],
                {"enabled": True, "namespace": "project:example-catalog"},
            )

    def test_context_services_require_isolated_project_key(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            brief.write_text("# Brief\\n", encoding="utf-8")
            missing_key = self.invoke(
                BOOTSTRAP,
                "--target", str(root / "missing-key"), "--brief", str(brief),
                "--project-name", "Missing Key", "--tela-space", "example-catalog",
                expect=1,
            )
            self.assertIn("requires --project-key", missing_key.stderr)
            wrong_namespace = self.invoke(
                BOOTSTRAP,
                "--target", str(root / "wrong-namespace"), "--brief", str(brief),
                "--project-name", "Wrong Namespace", "--project-key", "example-catalog",
                "--cortex-namespace", "project:crm",
                expect=1,
            )
            self.assertIn("must equal project:<project-key>", wrong_namespace.stderr)

    def test_node_profile_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            target = root / "project"
            brief.write_text("# Brief\n", encoding="utf-8")
            args = (
                "--target", str(target), "--brief", str(brief),
                "--project-name", "Node DB", "--profile", "node-postgresql",
            )
            self.invoke(BOOTSTRAP, *args)
            second = self.invoke(BOOTSTRAP, *args)
            self.assertIn("created=0", second.stdout)
            self.assertTrue((target / "scripts/verification/dependencies.sh").stat().st_mode & 0o100)
            self.invoke(VALIDATE, "--target", str(target))

    def test_explicit_agent_topology(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            target = root / "project"
            brief.write_text("# Brief\\n", encoding="utf-8")
            self.invoke(
                BOOTSTRAP,
                "--target", str(target), "--brief", str(brief),
                "--project-name", "Topology", "--profile", "generic",
            )

            expected = {
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
                "auditor.toml": (
                    'model = "gpt-6-luna"',
                    'model_reasoning_effort = "high"',
                    'sandbox_mode = "read-only"',
                    'approval_policy = "never"',
                ),
                "security_reviewer.toml": (
                    'model = "gpt-6-luna"',
                    'model_reasoning_effort = "high"',
                    'sandbox_mode = "read-only"',
                    'approval_policy = "never"',
                ),
                "test_reviewer.toml": (
                    'model = "gpt-6-luna"',
                    'model_reasoning_effort = "high"',
                    'sandbox_mode = "read-only"',
                    'approval_policy = "never"',
                ),
                "maintainability_reviewer.toml": (
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
            agents = target / ".codex" / "agents"
            self.assertEqual({path.name for path in agents.iterdir()}, set(expected))
            for filename, markers in expected.items():
                text = (agents / filename).read_text(encoding="utf-8")
                for marker in markers:
                    self.assertIn(marker, text)

            for filename in ("luna_auditor.toml", "glm_auditor.toml", "glm_flash_auditor.toml"):
                text = (agents / filename).read_text(encoding="utf-8")
                self.assertIn('sandbox_mode = "read-only"', text)
                self.assertIn('approval_policy = "never"', text)

            routing = (target / "docs/codex/MODEL_ROUTING.md").read_text(encoding="utf-8")
            for marker in (
                "two different axes",
                "GLM auditor profiles deliberately have the same sandbox and approval",
                "zai_coding",
                "does not trigger",
                "ZCode physical combine",
                "nested codex exec",
                "event-driven",
            ):
                self.assertIn(marker, routing)

            agents_contract = (target / "AGENTS.md").read_text(encoding="utf-8")
            for marker in (
                "Two routing axes",
                "glm_flash_auditor",
                "same sandbox and approval permissions",
                "No combine-handoff is needed",
            ):
                self.assertIn(marker, agents_contract)

            handoff = (target / "skills/combine-handoff/SKILL.md").read_text(encoding="utf-8")
            self.assertIn("Do not use this skill for a model-provider switch inside Codex", handoff)
            self.assertIn("Provider-neutral roles cross the boundary", handoff)
            self.assertIn("прими работу", handoff)
            self.assertIn("перехожу на ZCode", handoff)
            self.assertIn("native orchestrator", handoff)

            orchestrator = (target / "docs/ORCHESTRATOR_PROTOCOL.md").read_text(encoding="utf-8")
            for marker in (
                "ZCode uses native GLM orchestration",
                "full orchestrated combine",
                "one writer",
                "independent read-only auditor(s)",
                "Final reviewer",
                "event-driven",
                "прими работу",
            ):
                self.assertIn(marker, orchestrator)

            manifest = json.loads(
                (target / ".codex/project-foundation.json").read_text(encoding="utf-8")
            )
            self.assertEqual(manifest["foundation_version"], "0.6.0")


    def test_routing_checker_rejects_material_model_and_permission_drift(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            target = root / "project"
            brief.write_text("# Brief\n", encoding="utf-8")
            self.invoke(BOOTSTRAP, "--target", str(target), "--brief", str(brief),
                        "--project-name", "Routing", "--profile", "generic")
            checker = target / "scripts/validate-model-routing.py"
            profile = target / ".codex/agents/security_reviewer.toml"
            original = profile.read_text(encoding="utf-8")
            profile.write_text(original.replace('model = "gpt-6-luna"',
                                                'model = "gpt-6-sol"'), encoding="utf-8")
            result = self.invoke(checker, "--root", str(target), expect=1)
            self.assertIn("security_reviewer.model", result.stderr)
            self.invoke(VALIDATE, "--target", str(target), expect=1)
            profile.write_text(original.replace('sandbox_mode = "read-only"',
                                                'sandbox_mode = "workspace-write"'), encoding="utf-8")
            result = self.invoke(checker, "--root", str(target), expect=1)
            self.assertIn("security_reviewer.sandbox_mode", result.stderr)
            profile.write_text(original, encoding="utf-8")
            self.invoke(checker, "--root", str(target))
            workflow = (target / ".github/workflows/model-routing.yml").read_text(encoding="utf-8")
            self.assertIn("github.event.pull_request.head.sha", workflow)
            self.assertIn('test "$(git rev-parse HEAD)" = "$CANDIDATE_SHA"', workflow)

    def test_native_zcode_profiles_are_checked_separately(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            target = root / "project"
            native = root / "native-agents"
            native.mkdir()
            brief.write_text("# Brief\n", encoding="utf-8")
            self.invoke(BOOTSTRAP, "--target", str(target), "--brief", str(brief),
                        "--project-name", "Routing", "--profile", "generic")
            for role in ("writer", "auditor", "security-reviewer", "test-reviewer", "final-judge"):
                name = f"example-{role}"
                model = "GLM-5.3" if role == "final-judge" else "GLM-5.3-Flash"
                tools = "" if role == "writer" else "tools:\n  - Read\n  - Grep\n  - Glob\n"
                (native / f"{name}.md").write_text(
                    f"---\nname: {name}\nmodel: account:zai-example/{model}\n"
                    f"thoughtLevel: max\ninjectAgentsMd: true\n{tools}---\n",
                    encoding="utf-8",
                )
            checker = target / "scripts/validate-model-routing.py"
            self.invoke(checker, "--root", str(target), "--zcode-dir", str(native),
                        "--zcode-prefix", "example")
            path = native / "example-security-reviewer.md"
            path.write_text(path.read_text(encoding="utf-8").replace(
                "GLM-5.3-Flash", "GLM-5.3"), encoding="utf-8")
            result = self.invoke(checker, "--root", str(target), "--zcode-dir", str(native),
                                 "--zcode-prefix", "example", expect=1)
            self.assertIn("example-security-reviewer.model", result.stderr)

    def test_refuses_overwrite(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            target = root / "project"
            target.mkdir()
            (target / "AGENTS.md").write_text("existing\n", encoding="utf-8")
            brief.write_text("# Brief\n", encoding="utf-8")
            result = self.invoke(
                BOOTSTRAP,
                "--target", str(target), "--brief", str(brief),
                "--project-name", "Conflict", "--profile", "generic",
                expect=1,
            )
            self.assertIn("different target files", result.stderr.lower())

    def test_rejects_symlink_brief(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            actual = root / "actual.md"
            brief = root / "brief.md"
            actual.write_text("# Brief\n", encoding="utf-8")
            brief.symlink_to(actual)
            result = self.invoke(
                BOOTSTRAP,
                "--target", str(root / "project"), "--brief", str(brief),
                "--project-name", "Symlink", expect=1,
            )
            self.assertIn("non-symlink", result.stderr)

    def test_rejects_symlink_target(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            actual = root / "actual"
            target = root / "project"
            brief = root / "brief.md"
            actual.mkdir()
            target.symlink_to(actual, target_is_directory=True)
            brief.write_text("# Brief\n", encoding="utf-8")
            result = self.invoke(
                BOOTSTRAP,
                "--target", str(target), "--brief", str(brief),
                "--project-name", "Symlink target", expect=1,
            )
            self.assertIn("target must not be a symlink", result.stderr)

    def test_rejects_symlinked_output_parent(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            target = root / "project"
            outside = root / "outside"
            brief = root / "brief.md"
            target.mkdir()
            outside.mkdir()
            (target / "docs").symlink_to(outside, target_is_directory=True)
            brief.write_text("# Brief\n", encoding="utf-8")
            result = self.invoke(
                BOOTSTRAP,
                "--target", str(target), "--brief", str(brief),
                "--project-name", "Symlink parent", expect=1,
            )
            self.assertIn("output parent must not be a symlink", result.stderr)
            self.assertEqual(list(outside.iterdir()), [])

    def test_rejects_symlink_foundation_plan(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            brief = root / "brief.md"
            actual = root / "actual-plan.md"
            plan = root / "plan.md"
            brief.write_text("# Brief\n", encoding="utf-8")
            actual.write_text("# Plan\n", encoding="utf-8")
            plan.symlink_to(actual)
            result = self.invoke(
                BOOTSTRAP,
                "--target", str(root / "project"), "--brief", str(brief),
                "--foundation-plan", str(plan), "--project-name", "Plan",
                expect=1,
            )
            self.assertIn("foundation plan must be a regular non-symlink", result.stderr)


if __name__ == "__main__":
    unittest.main()
