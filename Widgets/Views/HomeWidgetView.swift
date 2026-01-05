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
        switch family {
        case .systemLarge:
            return AnyView(largeState(snapshot))
        default:
            return AnyView(mediumState(snapshot))
        }
    }

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        switch family {
        case .systemLarge:
            return AnyView(largeSetupState(snapshot))
        default:
            return AnyView(mediumSetupState(snapshot))
        }
    }

    private func mediumSetupState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(snapshot)
            focusList(snapshot)

            Spacer(minLength: 8)

            Text("Set today’s focuses to begin.")
                .font(WidgetTypography.caption)
                .foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func largeSetupState(_ snapshot: WidgetSnapshot) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                header(snapshot)
                focusList(snapshot)

                Spacer(minLength: 8)

                Text("Set today’s focuses to begin.")
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            YearPreviewWidgetView(preview: snapshot.yearPreview, palette: palette)
                .frame(width: 150)
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

    private func mediumState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(snapshot)
            focusList(snapshot)
            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func largeState(_ snapshot: WidgetSnapshot) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                header(snapshot)
                focusList(snapshot)
                Spacer(minLength: 8)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            YearPreviewWidgetView(preview: snapshot.yearPreview, palette: palette)
                .frame(width: 150)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

private struct YearPreviewWidgetView: View {
    let preview: WidgetYearPreview?
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Year")
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Text(verbatim: yearText)
                    .font(WidgetTypography.badge)
                    .foregroundStyle(palette.textPrimary)
            }

            if let preview, !preview.statuses.isEmpty {
                YearPreviewGrid(statuses: preview.statuses, palette: palette)
                    .frame(height: 90)
                    .background(palette.surface.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Text("Open 10x to sync year")
                    .font(WidgetTypography.caption)
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 90)
                    .background(palette.surface.opacity(0.6))
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

    private var footerText: String {
        guard let preview, preview.totalDays > 0 else { return "Year progress" }
        return "\(String(format: "%.0f%%", preview.yearCompletionPercent)) • \(preview.daysLeft)d left"
    }
}

private struct YearPreviewGrid: View {
    let statuses: [WidgetYearDayStatus]
    let palette: ThemePalette

    var body: some View {
        GeometryReader { proxy in
            let spacingX: CGFloat = 3
            let spacingYMin: CGFloat = 2
            let layout = YearPreviewGridLayout.layout(
                for: proxy.size,
                totalDays: statuses.count,
                spacingX: spacingX,
                spacingYMin: spacingYMin,
                minColumns: 18,
                maxColumns: 26
            )
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacingX), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: layout.spacingY) {
                ForEach(Array(statuses.enumerated()), id: \.offset) { _, status in
                    Circle()
                        .fill(color(for: status))
                        .frame(width: layout.dotSize, height: layout.dotSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func color(for status: WidgetYearDayStatus) -> Color {
        switch status {
        case .success:
            return palette.accent
        case .incomplete:
            return palette.complete
        case .emptyToday:
            return palette.textSecondary
        case .emptyPast:
            return palette.textMuted
        case .future:
            return palette.surface
        }
    }
}

private enum YearPreviewGridLayout {
    static func layout(
        for size: CGSize,
        totalDays: Int,
        spacingX: CGFloat,
        spacingYMin: CGFloat,
        minColumns: Int,
        maxColumns: Int
    ) -> (columns: Int, dotSize: CGFloat, spacingY: CGFloat) {
        guard totalDays > 0 else { return (columns: 1, dotSize: 4, spacingY: spacingYMin) }

        var bestColumns = minColumns
        var bestDotSize: CGFloat = 0
        var bestSpacingY = spacingYMin

        for columns in minColumns...maxColumns {
            let rows = Int(ceil(Double(totalDays) / Double(columns)))
            guard rows > 0 else { continue }
            let widthDot = (size.width - spacingX * CGFloat(columns - 1)) / CGFloat(columns)
            let heightDot = (size.height - spacingYMin * CGFloat(rows - 1)) / CGFloat(rows)
            let rawDot = min(widthDot, heightDot)
            let dotSize = max(2, floor(rawDot))
            let totalDotHeight = CGFloat(rows) * dotSize
            let availableSpacing = max(0, size.height - totalDotHeight)
            let spacingY = rows > 1 ? max(spacingYMin, availableSpacing / CGFloat(rows - 1)) : 0

            if dotSize > bestDotSize {
                bestDotSize = dotSize
                bestColumns = columns
                bestSpacingY = spacingY
            }
        }

        return (columns: bestColumns, dotSize: bestDotSize, spacingY: bestSpacingY)
    }
}
