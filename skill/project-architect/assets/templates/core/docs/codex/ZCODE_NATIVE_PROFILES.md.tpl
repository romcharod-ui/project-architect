# Native ZCode profiles — {{PROJECT_NAME}}

This project records the routing contract in `AGENTS.md`. ZCode stores its
native agent profiles in the user's application settings, outside Git. The
repository bootstrap cannot install or authenticate those profiles on behalf
of the owner. Create or import the five native roles on each ZCode host before
assigning a checkpoint, using one stable lowercase project prefix.

| Profile suffix | Model | Effort | Tools |
|---|---|---|---|
| `-writer` | GLM-5.3-Flash | max | normal writer tools |
| `-auditor` | GLM-5.3-Flash | max | Read, Grep, Glob only |
| `-security-reviewer` | GLM-5.3-Flash | max | Read, Grep, Glob only |
| `-test-reviewer` | GLM-5.3-Flash | max | Read, Grep, Glob only |
| `-final-judge` | GLM-5.3 | max | Read, Grep, Glob only |

For example, with prefix `example`, the native profile names are
`example-writer`, `example-auditor`, `example-security-reviewer`,
`example-test-reviewer`, and `example-final-judge`. Bind each to the owner's
currently authorized Z.ai account/provider and the exact model above. Set
`injectAgentsMd: true` for all. Keep reviewers read-only. Set the parent
coordinator to GLM-5.3/max in the ZCode task itself. Do not assume a provider
or billing plan from another machine, and never copy tokens into the repo.

On the host that will execute ZCode, check the native profile directory:

```text
python3 scripts/validate-model-routing.py --zcode-dir <native-profile-dir> --zcode-prefix <prefix>
```

This is a static local check. At each checkpoint inspect sanitized actual
request metadata for coordinator, writer, all three review lanes, and final
judge: provider, model, effort when available, status and timestamp. Retain
only those safe fields in the evidence record. A matching profile or agent
self-report does not prove the request ran on that route. Reject and rerun any
lane with a material mismatch; do not silently use a paid API or exhausted
account fallback.
