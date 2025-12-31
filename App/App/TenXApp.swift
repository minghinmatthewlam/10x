import SwiftUI
import SwiftData
import TenXShared
import WidgetKit

@main
struct TenXApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeController = ThemeController()
    private let container = ModelContainerFactory.make()

    init() {
        UIKitAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    private var rootView: some View {
        ThemedRootView()
            .environmentObject(appState)
            .environmentObject(themeController)
            .modelContainer(container)
            .onOpenURL { url in
                appState.handle(url: url)
            }
    }
}
