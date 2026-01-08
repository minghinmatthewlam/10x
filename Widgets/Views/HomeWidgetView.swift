import SwiftUI
import WidgetKit
import TenXShared

struct HomeWidgetView: View {
    let snapshot: WidgetSnapshot?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var family
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
                emptyState(text: WidgetCopy.openToGetStarted)
            case .needsSetup:
                if snapshot.focuses.isEmpty {
                    emptyState(text: WidgetCopy.setTodaysFocusesCurly)
                } else {
                    setupState(snapshot)
                }
            case .inProgress, .complete:
                progressState(snapshot)
            }
        } else {
            emptyState(text: WidgetCopy.openTenXToGetStarted)
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
        switch family {
        case .systemLarge:
            return AnyView(LargeWidgetContent(snapshot: snapshot,
                                              palette: palette,
                                              showsSetupMessage: false))
        default:
            return AnyView(MediumWidgetContent(preview: snapshot.yearPreview,
                                               palette: palette))
        }
    }

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        switch family {
        case .systemLarge:
            return AnyView(LargeWidgetContent(snapshot: snapshot,
                                              palette: palette,
                                              showsSetupMessage: true))
        default:
            return AnyView(MediumWidgetContent(preview: snapshot.yearPreview,
                                               palette: palette))
        }
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

private struct MediumWidgetContent: View {
    let preview: WidgetYearPreview?
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            YearPreviewWidgetView(preview: preview,
                                  palette: palette,
                                  layout: .medium)
            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct LargeWidgetContent: View {
    let snapshot: WidgetSnapshot
    let palette: ThemePalette
    let showsSetupMessage: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    BrandLabel(palette: palette)
                    FocusListView(focuses: snapshot.focuses,
                                  palette: palette,
                                  showsHeader: true)
                    if showsSetupMessage {
                        Text(WidgetCopy.setTodaysFocusesToBegin)
                            .font(WidgetTypography.caption)
                            .foregroundStyle(palette.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                StreakBadgeView(streak: snapshot.streak, palette: palette)
            }

            Spacer(minLength: 8)

            YearPreviewWidgetView(preview: snapshot.yearPreview,
                                  palette: palette,
                                  layout: .large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct BrandLabel: View {
    let palette: ThemePalette

    var body: some View {
        Text("10x")
            .font(WidgetTypography.title)
            .foregroundStyle(palette.textPrimary)
    }
}

private struct FocusListView: View {
    let focuses: [WidgetSnapshot.Focus]
    let palette: ThemePalette
    let showsHeader: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsHeader {
                Text(WidgetCopy.focusesLabel)
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
            }
            ForEach(Array(focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
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
}

private struct StreakBadgeView: View {
    let streak: Int
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(WidgetTypography.badge)
                    .foregroundStyle(streak > 0 ? palette.accent : palette.textMuted)
                Text("\(streak)")
                    .font(WidgetTypography.badge)
                    .foregroundStyle(palette.textPrimary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(palette.surface.opacity(0.9))
            .clipShape(Capsule())
        }
        .frame(width: 70, alignment: .topTrailing)
    }
}

private struct YearPreviewWidgetView: View {
    let preview: WidgetYearPreview?
    let palette: ThemePalette
    let layout: YearPreviewLayout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(brandText)
                    .font(WidgetTypography.caption)
                    .foregroundStyle(brandColor)
                Spacer()
                Text(verbatim: yearText)
                    .font(WidgetTypography.badge)
                    .foregroundStyle(palette.textPrimary)
            }

            if let preview, !preview.statuses.isEmpty {
                YearProgressDotGrid(colors: preview.statuses.map(\.color),
                                    inset: 6,
                                    spacingXMin: 3,
                                    spacingYMin: 2,
                                    minColumns: 18,
                                    maxColumns: 26)
                    .frame(height: gridHeight)
                    .background(palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Text(WidgetCopy.openToSyncYear)
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: gridHeight)
                    .background(palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Text(footerText)
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)
        }
    }

    private var yearText: String {
        guard let preview else { return "—" }
        return String(preview.year)
    }

    private var brandText: String {
        switch layout {
        case .medium:
            return "10x"
        case .large:
            return "Year"
        }
    }

    private var brandColor: Color {
        switch layout {
        case .medium:
            return palette.textPrimary
        case .large:
            return palette.textSecondary
        }
    }

    private var footerText: String {
        guard let preview, preview.totalDays > 0 else { return WidgetCopy.yearProgressFallback }
        return "\(String(format: "%.0f%%", preview.yearCompletionPercent)) • \(preview.daysLeft)d left"
    }

    private var gridHeight: CGFloat {
        switch layout {
        case .medium:
            return 92
        case .large:
            return 110
        }
    }
}

private enum YearPreviewLayout {
    case medium
    case large
}
