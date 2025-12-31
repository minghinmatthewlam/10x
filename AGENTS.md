Read `~/dev/agent-guards/AGENTS.md` for global guidelines.

Project notes:
- CI runs `swiftlint lint --strict --reporter github-actions-logging` (warnings fail CI). Run `swiftlint lint --strict --config .swiftlint.yml` before push.
- Run `xcodegen generate` (or `make generate`) after editing `project.yml`.
- Devices: `xcrun xctrace list devices` and `xcrun devicectl device install app --device <id> <app path>`.
- SwiftLint gotchas: avoid `force_unwrapping`; keep `vertical_whitespace_closing_braces`, `trailing_closure`, and `vertical_parameter_alignment_on_call` clean.
