import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var showDailySetup: Bool = false
    @Published var showSettingsSheet: Bool = false

    func handle(url: URL) {
        guard let route = AppRouter.route(for: url) else { return }
        switch route {
        case .home:
            showDailySetup = false
            showSettingsSheet = false
        case .setup:
            showDailySetup = true
            showSettingsSheet = false
        case .settings:
            showDailySetup = false
            showSettingsSheet = true
        }
    }
}
