import WidgetKit
import SwiftUI
import TenXShared

struct TenXWidgetsEntryView: View {
    let entry: WidgetSnapshotEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            LockWidgetView(snapshot: entry.snapshot)
        case .systemSmall:
            SmallHomeWidgetView(snapshot: entry.snapshot)
        default:
            HomeWidgetView(snapshot: entry.snapshot)
        }
    }
}

struct TenXWidgets: Widget {
    let kind: String = "TenXWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: SnapshotTimelineProvider()) { entry in
            TenXWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("10x")
        .description("Track today’s focuses and streak.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular])
    }
}

@main
struct TenXWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TenXWidgets()
    }
}
