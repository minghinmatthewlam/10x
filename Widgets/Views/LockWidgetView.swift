import SwiftUI
import WidgetKit
import TenXShared

struct LockWidgetView: View {
    let snapshot: WidgetSnapshot?
    @Environment(\.colorScheme) private var colorScheme
    private var palette: ThemePalette {
        AppearanceModeStore.palette(systemScheme: colorScheme)
    }

    var body: some View {
        ZStack {
            if let snapshot {
                let total = max(snapshot.focuses.count, 1)
                Gauge(value: Double(snapshot.completedCount), in: 0...Double(total)) {
                    Image(systemName: "target")
                } currentValueLabel: {
                    Text("\(snapshot.completedCount)")
                        .font(WidgetTypography.caption)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(snapshot.completedCount >= total ? palette.complete : palette.accent)
            } else {
                Image(systemName: "target")
            }
        }
        .containerBackground(Color.clear, for: .widget)
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
