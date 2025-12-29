# Build & Tooling

## Prereqs

- Xcode 15+
- iOS 17+ SDK
- Xcodegen installed (via Homebrew)

## Regenerate project

```sh
xcodegen generate
```

## Build (CLI)

```sh
xcodebuild -project TenX.xcodeproj -scheme TenX -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```

## Test (CLI)

```sh
xcodebuild -project TenX.xcodeproj -scheme TenXTests -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' test
```

## App Group / Bundle IDs

- App: `com.matthewlam.tenx`
- Widgets: `com.matthewlam.tenx.widgets`
- App Group: `group.com.matthewlam.tenx`

Update these in `project.yml`, entitlements, and `SharedConstants` if they change.
