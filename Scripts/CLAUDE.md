# Scripts constraints

Build, sign, notarize, and package scripts for distribution.

Standing decisions:

- Atomic and composable: one script, one job. No mega-script. Compose them (for
  example, a release step that calls build, then notarize, then package) rather
  than inlining everything into one file.
- Gated operations (`codesign`, `xcrun notarytool submit`, `gh release create`,
  Homebrew tap pushes) require explicit approval; see `.claude/settings.json`.
- Never hardcode signing identities or credentials; read them from the
  environment or keychain.
