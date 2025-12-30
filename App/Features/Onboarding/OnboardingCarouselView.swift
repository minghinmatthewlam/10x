import SwiftUI

struct OnboardingCarouselView: View {
    let onComplete: () -> Void
    @Environment(\.tenxTheme) private var theme
    @State private var stepIndex = 0

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Why 10x",
            subtitle: "Exponential, not incremental",
            description: "10x thinking isn’t about 10x more work—it’s a different, exponentially easier approach.",
            systemImage: "target"
        ),
        OnboardingStep(
            title: "Focuses for 10x",
            subtitle: "1–3 goals, exponential returns",
            description: "10x growth comes from fewer, higher‑leverage goals. Less work, more gains and clarity.",
            systemImage: "square.and.pencil"
        ),
        OnboardingStep(
            title: "Build the streak",
            subtitle: "Complete 2+ focuses",
            description: "Two wins a day keeps your momentum alive.",
            systemImage: "flame.fill"
        ),
        OnboardingStep(
            title: "Weekly progress",
            subtitle: "Review the week",
            description: "Use weekly progress to learn what works and reset fast.",
            systemImage: "chart.line.uptrend.xyaxis"
        )
    ]

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $stepIndex) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(spacing: 24) {
                            Image(systemName: step.systemImage)
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundStyle(theme.textPrimary)
                                .padding(.bottom, 12)

                            Text(step.title)
                                .font(.tenxTitle)
                                .foregroundStyle(theme.textPrimary)

                            Text(step.subtitle)
                                .font(.tenxBody)
                                .foregroundStyle(theme.textSecondary)

                            Text(step.description)
                                .font(.tenxSmall)
                                .foregroundStyle(theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .frame(maxWidth: 280)
                        }
                        .padding(.horizontal, 24)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Button(action: handleNext) {
                    HStack(spacing: 8) {
                        Text(stepIndex == steps.count - 1 ? "Get Started" : "Continue")
                        if stepIndex < steps.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button("Skip") {
                    onComplete()
                }
                .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Capsule()
                        .fill(index == stepIndex ? theme.textPrimary : theme.textMuted)
                        .frame(width: index == stepIndex ? 24 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.2), value: stepIndex)
                }
            }
        }
        .padding(.bottom, 12)
    }

    private func handleNext() {
        if stepIndex < steps.count - 1 {
            stepIndex += 1
        } else {
            onComplete()
        }
    }
}

private struct OnboardingStep {
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
}
