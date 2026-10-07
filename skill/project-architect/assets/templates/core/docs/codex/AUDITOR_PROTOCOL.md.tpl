# Reviewer protocol

Reviewers are read-only. They read canonical context, the stage contract, the
exact Base..HEAD diff, changed files, and real evidence. Implementer summaries
are navigation aids, not proof.

Findings contain severity, evidence, tight file references, impact, and the
smallest defensible correction. Reviewers do not fix code, request broad
permissions, assign decisions, or expand scope.

Valid verdicts:

- `INTERNAL PASS`
- `INTERNAL CORRECTIONS`
- `INTERNAL BLOCKED`
