# CI and release constraints

GitHub Actions workflows and release automation.

Standing decisions:

- Every issue uses the task template and carries self-contained context (what,
  why, constraints, acceptance criteria). Blank issues are disabled.
- Never commit signing identities, notarization credentials, or tokens; use
  encrypted Actions secrets.
- Releases attach a signed, notarized `.dmg`; the `gh release create` step is
  gated (see `.claude/settings.json`).
