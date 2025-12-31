import SwiftUI
import SwiftData
import TenXShared
import WidgetKit

@main
struct TenXApp: App {
    @StateObject private var appState = AppState()
    private let container = ModelContainerFactory.make()

    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

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
            .modelContainer(container)
            .onOpenURL { url in
                appState.handle(url: url)
            }
            .onAppear {
                syncAppearanceMode()
            }
            .onChange(of: appearanceMode) { _, _ in
                syncAppearanceMode()
            }
            .preferredColorScheme(AppAppearance.colorScheme(for: appearanceMode))
    }

    private func syncAppearanceMode() {
        AppearanceModeStore.updateSharedMode(appearanceMode)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
    }
}
