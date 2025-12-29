# 10x

10x is a focused daily goal app for iOS. It enforces three daily focuses tied to up to three active goals, tracks streaks with a “pending today doesn’t break” rule, and ships a widget that reads a small App Group snapshot instead of SwiftData directly.

## Requirements

- Xcode 15+
- iOS 17+ (SwiftData)

## Structure

- `App/` — iOS app (SwiftUI + SwiftData)
- `Widgets/` — widget extension
- `Shared/` — shared Swift package (deep links, widget snapshot)
- `Tests/` — unit tests
- `UITests/` — UI tests

## Setup

1. Create the App Group in the Apple Developer portal.
2. Enable the App Group for both the app and widget targets.
3. Update `SharedConstants.appGroupID` if you use a different identifier.
4. Add the URL scheme `tenx` with hosts `home`, `setup`, `goals`, `settings` in the app target.

## Development

### Quick Start

```bash
# Install tools and generate project
make setup

# Open in Xcode
make open
```

### Available Commands

```bash
make setup        # Install XcodeGen, SwiftLint, SwiftFormat
make generate     # Regenerate Xcode project
make build        # Build for iOS Simulator
make test         # Run unit tests
make lint         # Run SwiftLint
make format       # Auto-format code
make format-check # Check formatting without changes
make clean        # Clean build artifacts
make ci           # Run full CI checks locally
make install-hooks # Install pre-commit hook
```

### Code Quality

- **SwiftLint**: Static analysis (`.swiftlint.yml`)
- **SwiftFormat**: Code formatting (`.swiftformat`)
- **Pre-commit hook**: Run `make install-hooks` to lint before each commit

### CI

GitHub Actions runs on every push/PR:
- SwiftLint (strict mode)
- SwiftFormat check
- Build app + widgets
- Run tests

## Notes

- Widgets read `widget_snapshot.json` from the App Group container.
- Streaks do not break if today exists but has zero completed focuses.
- Notifications are local-only and **silent** by spec.

## License

See `LICENSE`.
