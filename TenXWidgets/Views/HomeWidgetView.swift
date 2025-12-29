import SwiftUI
import WidgetKit
import TenXShared

struct HomeWidgetView: View {
    let snapshot: WidgetSnapshot?

    var body: some View {
        ZStack {
            Color.black
            content
                .padding(16)
        }
        .widgetURL(defaultURL)
    }

    @ViewBuilder
    private var content: some View {
        guard let snapshot else {
            emptyState(text: "Open TenX to get started")
            return
        }

        switch snapshot.state {
        case .needsOnboarding:
            emptyState(text: "Set your goals in TenX")
        case .needsSetup:
            emptyState(text: "Set today’s focuses")
        case .inProgress, .complete:
            progressState(snapshot)
        }
    }

    private func emptyState(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TenX")
                .font(.headline)
                .foregroundStyle(.white)
            Text(text)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(snapshot.streak)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(snapshot.focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
                    HStack(spacing: 6) {
                        Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                        Text(focus.title)
                            .lineLimit(1)
                    }
                    .font(.caption2)
                    .foregroundStyle(.white)
                }
            }

            Spacer()

            HStack {
                ProgressRing(progress: Double(snapshot.completedCount) / 3)
                    .frame(width: 36, height: 36)
                Text("\(snapshot.completedCount)/3 complete")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var defaultURL: URL? {
        guard let snapshot else { return DeepLinks.url(for: .home) }
        switch snapshot.state {
        case .needsOnboarding:
            return DeepLinks.url(for: .goals)
        case .needsSetup:
            return DeepLinks.url(for: .setup)
        case .inProgress, .complete:
            return DeepLinks.url(for: .home)
        }
    }
}

private struct ProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
