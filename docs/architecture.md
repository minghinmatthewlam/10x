# Architecture

## Core invariants

- Exactly 3 focuses per day entry (`AppConstants.dailyFocusCount`).
- 1–3 active goals at any time (`AppConstants.maxActiveGoals`).
- Each focus must link to an active goal at creation/update time.
- Day identity uses `dayKey` (`yyyy-MM-dd`) instead of raw dates.

## Data model

- `TenXGoal` — active/archived goals.
- `DayEntry` — one per `dayKey`, contains 3 `DailyFocus`.
- `DailyFocus` — focus title, completion state, optional carryover metadata.

## Streak rules

- A day counts if it has an entry and at least one completed focus.
- If today exists with 0 completed focuses, streak displays yesterday’s streak (pending).
- Missing a day entry breaks streak.

## Carryover

- Carryover never edits yesterday. It pre-fills today’s setup with unfinished focuses.
- Carryover caps at 3 focuses.

## Widget pipeline

- Widgets never open SwiftData.
- App writes `widget_snapshot.json` to App Group on state changes.
- Widget reads JSON in timeline provider.

## Persistence fallback

- SwiftData uses the App Group container when available.
- If the App Group container is unavailable (e.g., not configured on simulator), the app falls back to the default store, then in-memory.

## Error handling

- `TenXStore` throws validation errors for UI to surface via alerts.
- UI surfaces errors via alerts (see `HomeView`, `DailySetupView`, `OnboardingContainerView`).
