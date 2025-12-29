import SwiftUI
import WidgetKit
import TenXShared

struct SmallHomeWidgetView: View {
    let snapshot: WidgetSnapshot?

    var body: some View {
        ZStack {
            Color.black
            content
                .padding(12)
        }
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
        VStack(alignment: .leading, spacing: 6) {
            Text("10x")
                .font(.caption)
                .foregroundStyle(.white)
            Text(text)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func setupState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            header(snapshot)
            focusList(snapshot)
            Spacer()
            Text("Tap to set focuses")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressState(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            header(snapshot)
            focusList(snapshot)
            Spacer()
            HStack(spacing: 6) {
                ProgressRing(progress: Double(snapshot.completedCount) / 3)
                    .frame(width: 22, height: 22)
                Text("\(snapshot.completedCount)/3")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func header(_ snapshot: WidgetSnapshot) -> some View {
        HStack {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.white)
            Spacer()
            Text("\(snapshot.streak)")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
                .foregroundStyle(.white)
        }
    }

    private func focusList(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(snapshot.focuses.prefix(3).enumerated()), id: \.offset) { _, focus in
                HStack(spacing: 4) {
                    Image(systemName: focus.isCompleted ? "checkmark.circle.fill" : "circle")
                        .imageScale(.small)
                    Text(focus.title)
                        .lineLimit(1)
                }
                .font(.caption2)
                .foregroundStyle(.white)
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
