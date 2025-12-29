import SwiftUI
import WidgetKit
import TenXShared

struct SmallHomeWidgetView: View {
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
            .padding(14)
            .containerBackground(theme.background, for: .widget)
            .widgetURL(defaultURL)
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot {
            switch snapshot.state {
            case .needsOnboarding:
                emptyState(text: "Open 10x to start")
            case .needsSetup:
                if snapshot.focuses.isEmpty {
                    emptyState(text: "Set today's focuses")
                } else {
                    setupState(snapshot)
                }
            case .inProgress, .complete:
                progressState(snapshot)
            }
        } else {
            emptyState(text: "Open TenX")
        }
    }

    private func emptyState(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("10x")
                .font(.callout.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Text(text)
                .font(.footnote)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            header(snapshot)
            focusList(snapshot)
            Spacer()
            Text("Tap to set focuses")
                .font(.footnote)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            header(snapshot)
            focusList(snapshot)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func header(_ snapshot: WidgetSnapshot) -> some View {
        HStack {
            Text("Today")
                .font(.callout.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Text("\(snapshot.streak)")
                .font(.footnote)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(theme.textPrimary.opacity(0.15))
                .clipShape(Capsule())
                .foregroundStyle(theme.textPrimary)
        }
    }

    private func focusList(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(snapshot.focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
                HStack(spacing: 4) {
                    Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                        .imageScale(.small)
                    Text(focus.title)
                        .lineLimit(1)
                }
                .font(.footnote)
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
