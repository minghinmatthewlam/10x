import SwiftUI
import WidgetKit
import TenXShared

struct HomeWidgetView: View {
    let snapshot: WidgetSnapshot?
    private var theme: ThemePalette {
        if let raw = snapshot?.theme,
           let theme = Theme(rawValue: raw) {
            return theme.palette
        }
        return ThemeStore.currentTheme().palette
    }

    var body: some View {
        content
            .padding(16)
            .containerBackground(theme.background, for: .widget)
            .widgetURL(defaultURL)
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot {
            switch snapshot.state {
            case .needsOnboarding:
                emptyState(text: "Open 10x to get started")
            case .needsSetup:
                if snapshot.focuses.isEmpty {
                    emptyState(text: "Set today’s focuses")
                } else {
                    setupState(snapshot)
                }
            case .inProgress, .complete:
                progressState(snapshot)
            }
        } else {
            emptyState(text: "Open TenX to get started")
        }
    }

    private func emptyState(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("10x")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
            Text(text)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressState(_ snapshot: WidgetSnapshot) -> some View {
        let total = max(snapshot.focuses.count, 1)
        return VStack(alignment: .leading, spacing: 12) {
            header(snapshot)
            focusList(snapshot)

            Spacer()

            HStack {
                ProgressRing(progress: Double(snapshot.completedCount) / Double(total),
                             theme: theme)
                    .frame(width: 36, height: 36)
            Text("\(snapshot.completedCount)/\(total) complete")
                .font(.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(snapshot)
            focusList(snapshot)

            Spacer()

            Text("Tap to set today’s focuses")
                .font(.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func header(_ snapshot: WidgetSnapshot) -> some View {
        HStack {
            Text("Today")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Text("\(snapshot.streak)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.textPrimary.opacity(0.15))
                .clipShape(Capsule())
                .foregroundStyle(theme.textPrimary)
        }
    }

    private func focusList(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(snapshot.focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
                HStack(spacing: 6) {
                    Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                    Text(focus.title)
                        .lineLimit(1)
                }
                .font(.caption2)
                .foregroundStyle(theme.textPrimary)
            }
        }
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
