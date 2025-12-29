import SwiftUI

struct OnboardingContainerView: View {
    let onComplete: () -> Void

    var body: some View {
        WelcomeView {
            onComplete()
        }
    }
}
