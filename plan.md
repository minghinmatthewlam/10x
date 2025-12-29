---

# Final merged plan (best of both, no lost details)

## High-level goals of the merge

1. **Hard invariants enforced in data layer**

   * 1–3 active goals
   * every day entry has **exactly 3 focuses**
   * each focus is linked to an active goal at creation time
2. **Timezone-robust day identity** using `dayKey` (`yyyy-MM-dd`)
3. **Widgets read a small App Group JSON snapshot**, not SwiftData directly
4. **Streak logic = “pending today doesn’t break”**
5. **Continue-yesterday = prefill today setup with unfinished items**, not retroactive edits to yesterday
6. **Spec compliance**: dark-first, haptics medium, **no sounds**, minimal UI

---

## A. Final folder / target layout

### Targets

* **TenX** (iOS app)
* **TenXWidgets** (Widget Extension)
* **TenXShared** (local Swift package used by both app + widgets)
* **TenXTests / TenXUITests**

### Repo structure (merged)

```
TenX/
  TenXApp/
    App/
      TenXApp.swift
      RootView.swift
      AppState.swift
      AppRouter.swift

    Models/
      TenXGoal.swift
      DayEntry.swift
      DailyFocus.swift
      AppConstants.swift

    Persistence/
      ModelContainerFactory.swift
      TenXStore.swift
      Migrations/
        TenXMigrationPlan.swift   // scaffold

    Services/
      DayKey.swift
      StreakEngine.swift
      NotificationScheduler.swift
      Haptics.swift
      WidgetSnapshotService.swift
      SignificantTimeChangeListener.swift

    Features/
      Onboarding/
        OnboardingContainerView.swift
        WelcomeView.swift
        GoalSetupView.swift
        OnboardingViewModel.swift

      Home/
        HomeView.swift
        HomeViewModel.swift
        FocusCardView.swift
        StreakBadgeView.swift
        IncompleteDayPromptView.swift

      DailySetup/
        DailySetupView.swift
        DailySetupViewModel.swift
        FocusInputRow.swift

      Goals/
        GoalsView.swift
        GoalsViewModel.swift
        GoalEditorView.swift
        ArchivedGoalsView.swift

      Settings/
        SettingsView.swift
        SettingsViewModel.swift
        NotificationTimePickerView.swift

    UI/
      Theme/
        Color+Theme.swift
        Color+Hex.swift
        Font+TenX.swift
      Components/
        PrimaryButtonStyle.swift
        FocusCardButtonStyle.swift
        ProgressRing.swift

    Utilities/
      UserDefaultsKeys.swift
      AppGroup.swift

    Resources/
      Assets.xcassets
      Localizable.strings

  TenXWidgets/
    TenXWidgets.swift
    Providers/
      SnapshotTimelineProvider.swift
    Views/
      HomeWidgetView.swift
      LockWidgetView.swift

  TenXShared/ (Swift Package)
    Sources/TenXShared/
      SharedConstants.swift
      DeepLinks.swift
      WidgetSnapshot.swift
      WidgetSnapshotStore.swift

  TenXTests/
    Helpers/TestContainerFactory.swift
    StreakEngineTests.swift
    DayKeyTests.swift
    TenXStoreTests.swift
```

**Rationale:** feature-first core (Plan A strength), with explicit UI/theme/utilities scaffolding (Plan B strength).

---

## B. App Groups + URL schemes (merged checklist)

### App Group steps (include both the practical and distribution path)

1. Apple Developer Portal → Identifiers → **App Groups** → create:

   * `group.com.yourname.tenx`
2. Xcode → TenX target → Signing & Capabilities → + App Groups → enable it
3. Xcode → TenXWidgets target → same
4. Centralize ID:

   * `TenXShared/Sources/TenXShared/SharedConstants.swift`

### Deep link scheme

Add to TenX app target Info:

* URL scheme: `tenx`
* Hosts: `home`, `setup`, `goals`, `settings`

---

## C. Persistence strategy (merged)

### 1) SwiftData inside the app

* App owns SwiftData `ModelContainer`.
* Widgets do **not** open SwiftData.

### 2) Widget snapshot in App Group (JSON)

* App writes `widget_snapshot.json` whenever relevant state changes.
* Widget reads it on timeline generation.

### 3) Optional: store SwiftData file in App Group container (Plan B idea, made safe)

This is optional but interview-friendly. If App Group is misconfigured, fall back to default store location.

---

## D. Updated models (merged)

### `TenXGoal` (add unarchive + stable uuid)

**File:** `TenXApp/Models/TenXGoal.swift`

```swift
import Foundation
import SwiftData

@Model
final class TenXGoal {
    @Attribute(.unique) var uuid: UUID
    var title: String
    var createdAt: Date
    var archivedAt: Date?

    @Relationship(inverse: \DailyFocus.goal)
    var focuses: [DailyFocus] = []

    init(uuid: UUID = UUID(),
         title: String,
         createdAt: Date = .now,
         archivedAt: Date? = nil) {
        self.uuid = uuid
        self.title = title
        self.createdAt = createdAt
        self.archivedAt = archivedAt
    }

    var isArchived: Bool { archivedAt != nil }

    func archive(now: Date = .now) {
        archivedAt = now
    }

    func unarchive() {
        archivedAt = nil
    }
}
```

### `DayEntry` (use `dayKey`, keep strict invariant)

**File:** `TenXApp/Models/DayEntry.swift`

```swift
import Foundation
import SwiftData

@Model
final class DayEntry {
    /// Stable local-day identifier ("yyyy-MM-dd"). Unique.
    @Attribute(.unique) var dayKey: String

    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \DailyFocus.day)
    var focuses: [DailyFocus] = []

    init(dayKey: String, createdAt: Date = .now) {
        self.dayKey = dayKey
        self.createdAt = createdAt
    }

    var sortedFocuses: [DailyFocus] {
        focuses.sorted { $0.sortOrder < $1.sortOrder }
    }

    var completedCount: Int {
        focuses.filter(\.isCompleted).count
    }

    /// Spec: streak maintained if >= 1 completed.
    var maintainsStreak: Bool { completedCount >= 1 }

    var isFullyComplete: Bool { completedCount == AppConstants.dailyFocusCount }
}
```

### `DailyFocus` (add `completedAt` + optional carry metadata)

**File:** `TenXApp/Models/DailyFocus.swift`

```swift
import Foundation
import SwiftData

@Model
final class DailyFocus {
    @Attribute(.unique) var uuid: UUID

    var title: String
    var sortOrder: Int

    var isCompleted: Bool
    var completedAt: Date?

    /// Optional: indicates this focus was carried from a previous dayKey.
    /// Helpful for future insights or UI labels.
    var carriedFromDayKey: String?

    var createdAt: Date

    @Relationship var day: DayEntry?
    @Relationship var goal: TenXGoal?

    init(uuid: UUID = UUID(),
         title: String,
         sortOrder: Int,
         isCompleted: Bool = false,
         completedAt: Date? = nil,
         carriedFromDayKey: String? = nil,
         createdAt: Date = .now) {
        self.uuid = uuid
        self.title = title
        self.sortOrder = sortOrder
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.carriedFromDayKey = carriedFromDayKey
        self.createdAt = createdAt
    }

    func setCompleted(_ completed: Bool, now: Date = .now) {
        isCompleted = completed
        completedAt = completed ? now : nil
    }
}
```

### Constants (Plan B improvement)

**File:** `TenXApp/Models/AppConstants.swift`

```swift
import Foundation

enum AppConstants {
    static let maxActiveGoals = 3
    static let dailyFocusCount = 3
    static let defaultNotificationHour = 8
    static let defaultNotificationMinute = 0

    /// Widget snapshot refresh fallback
    static let widgetRefreshMinutes = 30
}
```

---

## E. ModelContainerFactory (merged: safe App Group store URL + migration scaffold)

**File:** `TenXApp/Persistence/ModelContainerFactory.swift`

```swift
import Foundation
import SwiftData
import TenXShared

enum ModelContainerFactory {
    static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([TenXGoal.self, DayEntry.self, DailyFocus.self])

        // Optional: store SwiftData SQLite in App Group container.
        // If App Group is missing (misconfigured in dev), fall back to default.
        let storeURL: URL? = {
            guard !inMemory else { return nil }
            guard let base = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
            ) else { return nil }
            return base.appendingPathComponent("tenx.store")
        }()

        // Migration plan scaffold (see TenXMigrationPlan.swift).
        let migrationPlan = TenXMigrationPlan.self

        do {
            // NOTE: Depending on your SwiftData version, the initializer signature may vary.
            // The pattern below is the intended one: pass schema + optional url + migration plan.
            let config = ModelConfiguration(schema: schema,
                                           url: storeURL,
                                           isStoredInMemoryOnly: inMemory)

            return try ModelContainer(for: schema,
                                      migrationPlan: migrationPlan,
                                      configurations: [config])
        } catch {
            // Hard fallback: if App Group URL caused failure, retry with default location.
            do {
                let fallbackConfig = ModelConfiguration(schema: schema,
                                                       isStoredInMemoryOnly: inMemory)
                return try ModelContainer(for: schema,
                                          migrationPlan: migrationPlan,
                                          configurations: [fallbackConfig])
            } catch {
                fatalError("Failed to create SwiftData container: \(error)")
            }
        }
    }
}
```

**File:** `TenXApp/Persistence/Migrations/TenXMigrationPlan.swift`

```swift
import SwiftData

/// Start with a single schema version (V1). Add V2+ when you introduce breaking changes.
/// This matches Plan B’s migration scaffolding idea.
enum TenXMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TenXSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

/// V1 schema placeholder. When you create V2, define TenXSchemaV2 and add stages.
enum TenXSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TenXGoal.self, DayEntry.self, DailyFocus.self]
    }
}
```

---

## F. Store layer (merged: strict invariants + carryover drafts)

### Key responsibilities

* Validate constraints (max goals, exactly 3 focuses, goal linking required).
* Keep view models thin.
* Provide functions to:

  * create goals
  * archive/unarchive
  * fetch day entry by `dayKey`
  * create today entry from drafts
  * produce carryover drafts from yesterday unfinished tasks
  * toggle completion (set `completedAt`)
  * refresh widget snapshot after changes (via service call in VM/service)

**File:** `TenXApp/Persistence/TenXStore.swift` (key merged additions shown)

```swift
import Foundation
import SwiftData

@MainActor
final class TenXStore {
    let context: ModelContext

    init(context: ModelContext) { self.context = context }

    // MARK: - Drafts

    struct FocusDraft: Equatable {
        var title: String
        var goalUUID: UUID?
        var carriedFromDayKey: String?
    }

    // MARK: - Goals

    func fetchActiveGoals() throws -> [TenXGoal] {
        var d = FetchDescriptor<TenXGoal>(predicate: #Predicate { $0.archivedAt == nil })
        d.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        return try context.fetch(d)
    }

    func fetchAllGoals() throws -> [TenXGoal] {
        var d = FetchDescriptor<TenXGoal>()
        d.sortBy = [SortDescriptor(\.createdAt, order: .forward)]
        return try context.fetch(d)
    }

    func createGoal(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw StoreError.validation("Goal title is empty.") }

        let activeCount = try fetchActiveGoals().count
        guard activeCount < AppConstants.maxActiveGoals else {
            throw StoreError.validation("You can only have \(AppConstants.maxActiveGoals) active goals.")
        }

        context.insert(TenXGoal(title: trimmed))
        try context.save()
    }

    func archiveGoal(_ goal: TenXGoal) throws {
        let activeCount = try fetchActiveGoals().count
        guard activeCount > 1 else {
            throw StoreError.validation("You need at least 1 active goal.")
        }
        goal.archive()
        try context.save()
    }

    func unarchiveGoal(_ goal: TenXGoal) throws {
        let activeCount = try fetchActiveGoals().count
        guard activeCount < AppConstants.maxActiveGoals else {
            throw StoreError.validation("You already have \(AppConstants.maxActiveGoals) active goals.")
        }
        goal.unarchive()
        try context.save()
    }

    // MARK: - Day entries

    func fetchDayEntry(dayKey: String) throws -> DayEntry? {
        let d = FetchDescriptor<DayEntry>(predicate: #Predicate { $0.dayKey == dayKey })
        return try context.fetch(d).first
    }

    func fetchRecentDayEntries(limit: Int = 120) throws -> [DayEntry] {
        var d = FetchDescriptor<DayEntry>()
        d.sortBy = [SortDescriptor(\.dayKey, order: .reverse)]
        d.fetchLimit = limit
        return try context.fetch(d)
    }

    /// Returns 3 drafts for today based on yesterday unfinished focuses.
    /// - If yesterday had 0 unfinished, returns [].
    /// - If > 3 unfinished (shouldn’t happen), caps at 3.
    func carryoverDraftsIfNeeded(todayKey: String) throws -> [FocusDraft] {
        let yesterdayKey = DayKey.previous(dayKey: todayKey)
        guard let yesterday = try fetchDayEntry(dayKey: yesterdayKey) else { return [] }

        let unfinished = yesterday.sortedFocuses.filter { !$0.isCompleted }
        guard !unfinished.isEmpty else { return [] }

        return unfinished.prefix(AppConstants.dailyFocusCount).map { focus in
            FocusDraft(
                title: focus.title,
                goalUUID: focus.goal?.uuid,
                carriedFromDayKey: yesterdayKey
            )
        }
    }

    /// Creates today's DayEntry from exactly 3 drafts.
    /// Enforces: titles non-empty, goals set, goals active.
    func createDayEntry(todayKey: String, drafts: [FocusDraft]) throws {
        guard drafts.count == AppConstants.dailyFocusCount else {
            throw StoreError.validation("You must set exactly \(AppConstants.dailyFocusCount) focuses.")
        }
        guard (try fetchDayEntry(dayKey: todayKey)) == nil else {
            throw StoreError.validation("Today is already set.")
        }

        let activeGoals = try fetchActiveGoals()
        let activeByUUID = Dictionary(uniqueKeysWithValues: activeGoals.map { ($0.uuid, $0) })

        let entry = DayEntry(dayKey: todayKey)
        context.insert(entry)

        for (i, draft) in drafts.enumerated() {
            let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw StoreError.validation("Focus \(i + 1) is empty.")
            }
            guard let goalUUID = draft.goalUUID else {
                throw StoreError.validation("Focus \(i + 1) must be linked to a goal.")
            }
            guard let goal = activeByUUID[goalUUID] else {
                throw StoreError.validation("Selected goal is not active.")
            }

            let focus = DailyFocus(
                title: trimmed,
                sortOrder: i,
                carriedFromDayKey: draft.carriedFromDayKey
            )
            focus.day = entry
            focus.goal = goal

            entry.focuses.append(focus)
            context.insert(focus)
        }

        try context.save()
    }

    func toggleCompletion(_ focus: DailyFocus) throws {
        focus.setCompleted(!focus.isCompleted)
        try context.save()
    }
}

enum StoreError: Error, LocalizedError {
    case validation(String)

    var errorDescription: String? {
        switch self {
        case .validation(let msg): return msg
        }
    }
}
```

---

## G. StreakEngine (merged)

### Rules (final)

* A day **counts** if it has a DayEntry and `completedCount >= 1`.
* If today exists but has 0 completed: **streak shows yesterday’s streak** (pending day).
* Missing day entry breaks streak (consecutive days requirement).
* Provide `streakStartDayKey` for milestones.

**File:** `TenXApp/Services/StreakEngine.swift`

```swift
import Foundation

enum StreakEngine {
    static func currentStreak(todayKey: String, entries: [DayEntry]) -> Int {
        let byKey = Dictionary(uniqueKeysWithValues: entries.map { ($0.dayKey, $0) })

        let startKey: String = {
            if let today = byKey[todayKey], today.maintainsStreak {
                return todayKey
            } else {
                return DayKey.previous(dayKey: todayKey)
            }
        }()

        var streak = 0
        var cursor = startKey

        while true {
            guard let entry = byKey[cursor] else { break }
            guard entry.maintainsStreak else { break }
            streak += 1
            cursor = DayKey.previous(dayKey: cursor)
        }

        return streak
    }

    static func streakStartDayKey(todayKey: String, entries: [DayEntry]) -> String? {
        let byKey = Dictionary(uniqueKeysWithValues: entries.map { ($0.dayKey, $0) })
        let streak = currentStreak(todayKey: todayKey, entries: entries)
        guard streak > 0 else { return nil }

        // Determine which day is counted as day #1 (today if maintained, else yesterday).
        let startKey = (byKey[todayKey]?.maintainsStreak == true) ? todayKey : DayKey.previous(dayKey: todayKey)

        var cursor = startKey
        var remaining = streak - 1
        while remaining > 0 {
            cursor = DayKey.previous(dayKey: cursor)
            remaining -= 1
        }
        return cursor
    }
}
```

---

## H. Onboarding (merged: TabView welcome + goal setup + onboarding flag)

### Root gating logic (merge both approaches)

* Use `@AppStorage(hasCompletedOnboarding)` for intent
* Also fallback to onboarding if goals are empty

**File:** `TenXApp/App/RootView.swift`

```swift
import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Query private var allGoals: [TenXGoal]

    var body: some View {
        if !hasCompletedOnboarding || allGoals.isEmpty {
            OnboardingContainerView {
                hasCompletedOnboarding = true
            }
        } else {
            HomeShellView()
        }
    }
}
```

### OnboardingContainerView (Plan B UX, Plan A store discipline)

* Page 0: Welcome (philosophy points)
* Page 1: Goals input
* On complete: creates goals via `TenXStore`, sets onboarding flag

Use your existing Plan B view code style, but route persistence through `TenXStore` (not direct `modelContext.insert` scattered).

---

## I. Daily flow (merged: correct carryover semantics)

### State Machine Diagram

```
                    ┌─────────────────┐
                    │   App Launch    │
                    └────────┬────────┘
                             ▼
                ┌────────────────────────────┐
                │ hasCompletedOnboarding     │
                │ && activeGoals.count > 0 ? │
                └────────────┬───────────────┘
                             │
              ┌──────────────┴──────────────┐
              │ No                          │ Yes
              ▼                             ▼
    ┌──────────────────┐         ┌─────────────────────┐
    │ OnboardingFlow   │         │ todayEntry exists?  │
    │ (Welcome→Goals)  │         └──────────┬──────────┘
    └──────────────────┘                    │
                              ┌─────────────┴─────────────┐
                              │ Yes                       │ No
                              ▼                           ▼
                    ┌──────────────────┐    ┌─────────────────────────┐
                    │    HomeView      │    │ yesterdayEntry exists   │
                    │ (show 3 focuses) │    │ && has incomplete (< 3)?│
                    └──────────────────┘    └────────────┬────────────┘
                              ▲                          │
                              │           ┌──────────────┴──────────────┐
                              │           │ No                          │ Yes
                              │           ▼                             ▼
                              │  ┌─────────────────────┐   ┌─────────────────────────┐
                              │  │   DailySetupView    │   │ IncompleteDayPromptView │
                              │  │   (empty drafts)    │   │ "Continue?" / "Fresh?"  │
                              │  └──────────┬──────────┘   └────────────┬────────────┘
                              │             │                           │
                              │             │              ┌────────────┴────────────┐
                              │             │              │ Continue                │ Fresh
                              │             │              ▼                         ▼
                              │             │   ┌─────────────────────┐   ┌─────────────────────┐
                              │             │   │   DailySetupView    │   │   DailySetupView    │
                              │             │   │ (prefilled drafts)  │   │   (empty drafts)    │
                              │             │   └──────────┬──────────┘   └──────────┬──────────┘
                              │             │              │                         │
                              │             └──────────────┴─────────────────────────┘
                              │                            │
                              │                            ▼
                              │               ┌────────────────────────┐
                              │               │ User fills 3 focuses   │
                              │               │ + links each to goal   │
                              │               │ → "Start Day" tapped   │
                              │               └───────────┬────────────┘
                              │                           │
                              │                           ▼
                              │               ┌────────────────────────┐
                              │               │ createDayEntry(drafts) │
                              │               │ + write widget snapshot│
                              └───────────────┴────────────────────────┘
```

### Key Invariants

* **Never retroactively edit yesterday** - carryover creates NEW today entry with prefilled drafts
* **Exactly 3 focuses required** - cannot submit DailySetup with < 3
* **Goal link required** - each focus must reference an active goal

**Implementation note:** `DailySetupViewModel` accepts optional `initialDrafts: [FocusDraft]` for prefill.

---

## J. Haptics (merged)

* Keep Plan A’s `UIImpactFeedbackGenerator(.medium)` to match your spec.
* (Optional) Use Plan B’s `.sensoryFeedback` **instead of** manual calls if you want pure SwiftUI later, but don’t double-trigger.

---

## K. Notifications (merged: spec-compliant + debug testing)

### Final decisions

* `content.sound = nil` (spec)
* Provide `scheduleTestNotification()` under `#if DEBUG`
* Settings UI includes:

  * time picker (hour/minute)
  * status display (authorized/denied)
  * “Open Settings” button when denied

Remove Plan B’s `UIBackgroundModes remote-notification` recommendation; it’s not needed for local notifications.

---

## L. Widgets (merged: state machine + atomic JSON + midnight + periodic refresh)

### Snapshot model

Keep Plan A `WidgetSnapshot` (state + focuses + streak + completedCount + dayKey + generatedAt).

### Refresh policy

In timeline provider:

* nextMidnight = start of tomorrow
* periodic = now + 30 minutes
* policy = `.after(min(periodic, nextMidnight))`

This captures Plan B’s “refresh at midnight” intent without losing Plan A’s “don’t get stuck stale” protection.

### UI improvements to adopt from Plan B

* Add a **progress bar** in `.systemLarge`
* Optionally support `.accessoryRectangular` and `.accessoryInline` later (Phase 9 polish). MVP: circular only.

---

# Edge cases: consolidated handling matrix (merged + spec-accurate)

| Scenario                       | Detection                                              | Handling                                                                                                           |
| ------------------------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| First launch ever              | `!hasCompletedOnboarding` OR `allGoals.isEmpty`        | Show onboarding container (welcome → goals)                                                                        |
| User hasn’t set today focuses  | `fetchDayEntry(todayKey) == nil`                       | Show daily setup (or empty state CTA)                                                                              |
| Mid-day partial completion     | today entry exists, `completedCount` in 0…2            | Show Home with completion state; progress text updates                                                             |
| New day + yesterday incomplete | yesterday entry exists and `completedCount < 3`        | Present IncompleteDayPromptView listing unfinished focuses                                                         |
| Continue yesterday             | unfinished focuses exist                               | Open DailySetup prefilled with unfinished focuses; user fills remaining slots; then create today entry (exactly 3) |
| Add 4th goal attempt           | active goals == 3                                      | Disable add + show message                                                                                         |
| Archive last active goal       | active goals == 1                                      | Block archive; show alert                                                                                          |
| Un-complete a focus            | user taps completed focus                              | Show confirm dialog; on confirm toggle false                                                                       |
| Timezone changes / DST         | app receives significant time change OR dayKey changes | Use `dayKey` for identity; refresh state and snapshot                                                              |
| Widget with no data            | no snapshot file                                       | widget shows “Open app to set goals” (needsOnboarding)                                                             |
| Notification permission denied | UNAuthorizationStatus == .denied                       | show “Open Settings” button; don’t spam requests                                                                   |
| App opened from widget         | `onOpenURL` receives `tenx://...`                      | Router/AppState navigates to Setup or Home                                                                         |
| Future model changes           | schema version bump                                    | use `TenXMigrationPlan` scaffolding; avoid breaking changes without a stage                                        |

---

# Implementation phases (merged milestones)

## Phase 1: Foundation
- Create Xcode project with targets (TenX, TenXWidgets, TenXShared, TenXTests)
- Configure App Groups in portal + Xcode
- Implement Models: `TenXGoal`, `DayEntry`, `DailyFocus`, `AppConstants`
- Implement `DayKey` service
- Implement `ModelContainerFactory` with App Group URL + migration scaffold
- Implement `TenXStore` with all validation logic
- Write unit tests: `DayKeyTests`, `TenXStoreTests`

## Phase 2: Onboarding
- `OnboardingContainerView` (TabView pager)
- `WelcomeView` (philosophy intro)
- `GoalSetupView` + `OnboardingViewModel`
- Wire goal creation through `TenXStore`
- Set `hasCompletedOnboarding` flag on complete

## Phase 3: Daily Flow
- `AppState` + `AppRouter` for navigation
- `RootView` gating logic (onboarding vs home vs setup)
- `HomeView` + `HomeViewModel` (display today's focuses)
- `FocusCardView` with tap-to-complete + haptic
- `DailySetupView` + `DailySetupViewModel`
  - Accept optional `initialDrafts` for prefill
  - Validate exactly 3 focuses + goal links
- `IncompleteDayPromptView` (Continue / Start Fresh)
- `FocusInputRow` component

## Phase 4: Streak & Goals Management
- `StreakEngine` implementation (pending-today logic)
- `StreakBadgeView` component
- `GoalsView` + `GoalsViewModel`
- `GoalEditorView` for add/edit
- `ArchivedGoalsView`
- Archive/unarchive flow with validation
- Write `StreakEngineTests`

## Phase 5: Widget Pipeline
- Define `WidgetSnapshot` model in TenXShared
- Implement `WidgetSnapshotService` (atomic JSON write to App Group)
- Hook snapshot refresh after: daily setup complete, focus toggle, goal changes
- Implement `WidgetSnapshotStore` (read-only for widgets)

## Phase 6: Widgets
- `SnapshotTimelineProvider` with refresh policy: `min(30min, nextMidnight)`
- `HomeWidgetView` (medium + large sizes)
- `LockWidgetView` (circular accessory)
- Deep link URLs for widget taps
- Handle all widget states: needsOnboarding, needsSetup, inProgress, complete

## Phase 7: Notifications
- `NotificationScheduler` service
- Request permission flow (first daily setup)
- Schedule morning reminder at user-configured time
- `content.sound = nil` per spec
- `#if DEBUG` test notification helper

## Phase 8: Settings & Polish
- `SettingsView` + `SettingsViewModel`
- `NotificationTimePickerView`
- Appearance toggle (light/dark/system)
- Permission denied state with "Open Settings" button
- Theme: `Color+Theme`, `Font+TenX`
- Animations for completion, transitions
- `SignificantTimeChangeListener` for timezone/midnight

## Phase 9: Accessibility & Testing
- VoiceOver labels on all interactive elements
- Dynamic Type support
- UI tests for critical flows (onboarding, daily setup, completion)
- Edge case testing (see edge case matrix)

## Phase 10: Launch Prep
- App Store metadata (screenshots, description, keywords)
- Privacy policy
- TestFlight beta
- Final QA pass

---

# Testing plan (merged)

Adopt Plan B’s helper and Plan A’s logic boundaries.

## Unit tests

* `DayKeyTests`: make/previous/date conversion
* `StreakEngineTests`: pending-today behavior + missing day breaks + maintained day increments
* `TenXStoreTests`:

  * cannot create day entry with <3 drafts
  * cannot create day entry with missing goal link
  * cannot add 4th active goal
  * cannot archive last active goal
  * carryoverDrafts returns only unfinished tasks and caps at 3

## SwiftData in-memory container helper

Use Plan B’s idea, but include the full schema + factory.

---

# Final “merge” summary of what you should implement first

If you want the most leverage early:

1. **Models + DayKey + Store invariants** (this prevents rework later)
2. **Onboarding TabView + goal creation via TenXStore**
3. **Home state machine**: today exists → show; else carryover prompt → setup
4. **Daily setup**: accepts optional prefilled drafts, creates today entry only when 3 complete
5. **StreakEngine** (pending-today)
6. **Widget snapshot pipeline** (write atomic + reload)
7. **Widgets** (home medium/large + lock circular) using snapshot state
8. **Notifications** (sound nil + permission denied UX + debug test)
9. **Theme assets + accessibility sweep**
10. **Migration scaffolding + tests**

---