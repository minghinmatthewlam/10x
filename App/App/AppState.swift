import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var showDailySetup: Bool = false

    func handle(url: URL) {
        guard let route = AppRouter.route(for: url) else { return }
        switch route {
        case .home:
            selectedTab = .home
            showDailySetup = false
        case .setup:
            selectedTab = .home
            showDailySetup = true
        case .settings:
            selectedTab = .settings
            showDailySetup = false
        }
    }
}

enum AppTab: Hashable {
    case home
    case settings
}
