import WidgetKit
import SwiftUI
import TenXShared

struct WidgetSnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct SnapshotTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetSnapshotEntry {
        WidgetSnapshotEntry(date: .now, snapshot: WidgetSnapshot(state: .needsSetup,
                                                                 dayKey: "",
                                                                 streak: 0,
                                                                 completedCount: 0,
                                                                 focuses: [],
                                                                 generatedAt: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetSnapshotEntry) -> Void) {
        let snapshot = WidgetSnapshotStore().load()
        completion(WidgetSnapshotEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetSnapshotEntry>) -> Void) {
        let snapshot = WidgetSnapshotStore().load()
        let entry = WidgetSnapshotEntry(date: .now, snapshot: snapshot)

        let nextMidnight = Calendar.current.nextDate(after: .now,
                                                     matching: DateComponents(hour: 0, minute: 0),
                                                     matchingPolicy: .nextTime) ?? .now.addingTimeInterval(60 * 60 * 24)
        let periodic = Date().addingTimeInterval(60 * 30)
        let refreshDate = min(periodic, nextMidnight)

        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}
