import SwiftUI
import SwiftData

@main
struct TenXApp: App {
    @StateObject private var appState = AppState()
    private let container = ModelContainerFactory.make()

    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    @ViewBuilder
    private var rootView: some View {
        let baseView = ThemedRootView()
            .environmentObject(appState)
            .modelContainer(container)
            .onOpenURL { url in
                appState.handle(url: url)
            }
        if let scheme = AppAppearance.colorScheme(for: appearanceMode) {
            baseView.preferredColorScheme(scheme)
        } else {
            baseView
        }
    }
}
