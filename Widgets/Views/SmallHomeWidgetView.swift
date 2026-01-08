import SwiftUI
import WidgetKit
import TenXShared

struct SmallHomeWidgetView: View {
    let snapshot: WidgetSnapshot?
    @Environment(\.colorScheme) private var colorScheme
    private var palette: ThemePalette {
        AppearanceModeStore.palette(systemScheme: colorScheme)
    }

    var body: some View {
        content
            .padding(16)
            .containerBackground(palette.background, for: .widget)
            .widgetURL(defaultURL)
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot {
            switch snapshot.state {
            case .needsOnboarding:
                emptyState(text: WidgetCopy.openToStart)
            case .needsSetup:
                if snapshot.focuses.isEmpty {
                    emptyState(text: WidgetCopy.setTodaysFocusesPlain)
                } else {
                    setupState(snapshot)
                }
            case .inProgress, .complete:
                progressState(snapshot)
            }
        } else {
            emptyState(text: WidgetCopy.openTenX)
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

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(snapshot)
            focusList(snapshot)
            Spacer()
            Text(WidgetCopy.setTodaysFocusesToBegin)
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(snapshot)
            focusList(snapshot)
            Spacer()
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
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(palette.surface.opacity(0.9))
            .clipShape(Capsule())
        }
    }

    private func focusList(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(WidgetCopy.focusesLabel)
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
            ForEach(Array(snapshot.focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
                HStack(spacing: 8) {
                    Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                        .imageScale(.small)
                        .foregroundStyle(focus.isCompleted ? palette.accent : palette.textMuted)
                    Text(focus.title)
                        .lineLimit(1)
                }
                .font(WidgetTypography.body)
                .foregroundStyle(palette.textPrimary)
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
