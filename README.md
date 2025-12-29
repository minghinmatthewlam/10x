# TenX

TenX is a focused daily goal app for iOS. It enforces three daily focuses tied to up to three active goals, tracks streaks with a “pending today doesn’t break” rule, and ships a widget that reads a small App Group snapshot instead of SwiftData directly.

## Requirements

- Xcode 15+
- iOS 17+ (SwiftData)

## Structure

- `TenXApp/` — iOS app (SwiftUI + SwiftData)
- `TenXWidgets/` — widget extension
- `TenXShared/` — shared Swift package (deep links, widget snapshot)
- `TenXTests/` — unit tests
- `TenXUITests/` — UI tests

## Setup

1. Create the App Group in the Apple Developer portal.
2. Enable the App Group for both the app and widget targets.
3. Update `SharedConstants.appGroupID` if you use a different identifier.
4. Add the URL scheme `tenx` with hosts `home`, `setup`, `goals`, `settings` in the app target.

## Development

- Build the TenX app target in Xcode.
- Run unit tests via Xcode’s test navigator.

## Notes

- Widgets read `widget_snapshot.json` from the App Group container.
- Streaks do not break if today exists but has zero completed focuses.
- Notifications are local-only and **silent** by spec.

## License

See `LICENSE`.
