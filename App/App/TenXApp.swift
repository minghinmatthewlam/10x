import SwiftUI
import SwiftData
import TenXShared
import WidgetKit

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
            .onAppear {
                syncAppearanceMode()
            }
            .onChange(of: appearanceMode) { _, _ in
                syncAppearanceMode()
            }
        if let scheme = AppAppearance.colorScheme(for: appearanceMode) {
            baseView.preferredColorScheme(scheme)
        } else {
            baseView
        }
    }

    private func syncAppearanceMode() {
        AppearanceModeStore.updateSharedMode(appearanceMode)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
    }
}
