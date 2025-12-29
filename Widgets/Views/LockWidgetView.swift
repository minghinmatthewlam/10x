import SwiftUI
import WidgetKit
import TenXShared

struct LockWidgetView: View {
    let snapshot: WidgetSnapshot?

    var body: some View {
        ZStack {
            if let snapshot {
                Gauge(value: Double(snapshot.completedCount), in: 0...3) {
                    Image(systemName: "target")
                } currentValueLabel: {
                    Text("\(snapshot.completedCount)")
                        .font(.caption2)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(snapshot.completedCount == 3 ? .green : .orange)
            } else {
                Image(systemName: "target")
            }
        }
        .widgetURL(defaultURL)
    }

    private var defaultURL: URL? {
        guard let snapshot else { return DeepLinks.url(for: .home) }
        switch snapshot.state {
        case .needsOnboarding:
            return DeepLinks.url(for: .home)
        case .needsSetup:
            return DeepLinks.url(for: .setup)
        case .inProgress, .complete:
            return DeepLinks.url(for: .home)
        }
    }
}
