import SwiftUI
import WidgetKit
import TenXShared

struct HomeWidgetView: View {
    let snapshot: WidgetSnapshot?
    @Environment(\.colorScheme) private var colorScheme
    private var palette: ThemePalette {
        AppearanceModeStore.palette(systemScheme: colorScheme)
    }

    var body: some View {
        content
            .padding(18)
            .containerBackground(palette.background, for: .widget)
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
                .font(WidgetTypography.title)
                .foregroundStyle(palette.textPrimary)
            Text(text)
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressState(_ snapshot: WidgetSnapshot) -> some View {
        let total = max(snapshot.focuses.count, 1)
        return VStack(alignment: .leading, spacing: 14) {
            header(snapshot)
            progressSummary(snapshot, total: total)
            focusList(snapshot)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            header(snapshot)
            focusList(snapshot)

            Spacer()

            Text("Set today’s focuses to begin.")
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func header(_ snapshot: WidgetSnapshot) -> some View {
        HStack {
            Text("10x")
                .font(WidgetTypography.title)
                .foregroundStyle(palette.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(WidgetTypography.badge)
                    .foregroundStyle(snapshot.streak > 0 ? palette.accent : palette.textMuted)
                Text("\(snapshot.streak)")
                    .font(WidgetTypography.badge)
                    .foregroundStyle(palette.textPrimary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(palette.surface.opacity(0.9))
            .clipShape(Capsule())
        }
    }

    private func focusList(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Focuses")
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
            ForEach(Array(snapshot.focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
                HStack(spacing: 8) {
                    Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(focus.isCompleted ? palette.accent : palette.textMuted)
                    Text(focus.title)
                        .lineLimit(1)
                }
                .font(WidgetTypography.body)
                .foregroundStyle(palette.textPrimary)
            }
        }
    }

    private func progressSummary(_ snapshot: WidgetSnapshot, total: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Progress")
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Text("\(snapshot.completedCount)/\(total)")
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
            }

            GeometryReader { proxy in
                let ratio = total == 0 ? 0 : CGFloat(snapshot.completedCount) / CGFloat(total)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(palette.surface)
                        .frame(height: 6)
                    Capsule()
                        .fill(palette.accent)
                        .frame(width: proxy.size.width * max(0, min(ratio, 1)), height: 6)
                }
            }
            .frame(height: 6)

            Text("Complete 2/3 focuses to increase your streak.")
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
                .lineLimit(2)
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
