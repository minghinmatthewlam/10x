# Widgets

## Snapshot schema

Defined in `Shared/Sources/TenXShared/WidgetSnapshot.swift`:

- `state`: needsOnboarding | needsSetup | inProgress | complete
- `dayKey`
- `streak`
- `completedCount`
- `focuses` (title + isCompleted)
- `generatedAt`

## Storage

- File name: `widget_snapshot.json`
- Location: App Group container (`SharedConstants.appGroupID`)

## Refresh policy

Timeline provider refreshes at the earlier of:
- 30 minutes from now
- Next midnight

## Deep links

Widget taps use `tenx://` URLs:
- needsOnboarding → `tenx://goals`
- needsSetup → `tenx://setup`
- inProgress/complete → `tenx://home`
