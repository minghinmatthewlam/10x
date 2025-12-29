import SwiftUI
import WidgetKit
import TenXShared

struct LockWidgetView: View {
    let snapshot: WidgetSnapshot?
    private var theme: ThemePalette {
        if let raw = snapshot?.theme,
           let theme = Theme(rawValue: raw) {
            return theme.palette
        }
        return ThemeStore.currentTheme().palette
    }

    var body: some View {
        ZStack {
            if let snapshot {
                let total = max(snapshot.focuses.count, 1)
                Gauge(value: Double(snapshot.completedCount), in: 0...Double(total)) {
                    Image(systemName: "target")
                } currentValueLabel: {
                    Text("\(snapshot.completedCount)")
                        .font(.caption2)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(snapshot.completedCount >= total ? theme.complete : theme.accent)
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
