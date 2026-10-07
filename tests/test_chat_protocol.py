from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ChatProtocolTests(unittest.TestCase):
    def test_start_routes_to_existing_files(self) -> None:
        start = (ROOT / "CHAT_START.md").read_text(encoding="utf-8")
        routed = (
            "chat/ARCHITECT_COORDINATOR.md",
            "chat/templates/PROJECT_BRIEF_TEMPLATE.md",
            "chat/templates/FOUNDATION_PLAN_TEMPLATE.md",
            "chat/templates/CODEX_BOOTSTRAP_PROMPT_TEMPLATE.md",
        )
        for relative in routed:
            self.assertIn(relative, start)
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_start_has_both_readiness_outcomes_and_boundaries(self) -> None:
        start = (ROOT / "CHAT_START.md").read_text(encoding="utf-8")
        for required in (
            "NEEDS OWNER DECISIONS",
            "READY FOR CODEX",
            "complete active conversation",
            "Do not perform repository",
            "dry-run",
            "stop before product implementation",
        ):
            self.assertIn(required, start)


if __name__ == "__main__":
    unittest.main()
