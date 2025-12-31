import SwiftUI
import WidgetKit
import TenXShared

@MainActor
final class ThemeController: ObservableObject {
    @AppStorage(UserDefaultsKeys.appearanceMode) private var storedMode = AppearanceMode.system.rawValue
    @Published private(set) var appearanceMode: AppearanceMode

    init() {
        appearanceMode = AppearanceMode(rawValue: storedMode) ?? .system
        sync()
    }

    func setAppearanceMode(_ mode: AppearanceMode) {
        guard mode != appearanceMode else { return }
        appearanceMode = mode
        storedMode = mode.rawValue
        sync()
    }

    var preferredColorScheme: ColorScheme? {
        AppAppearance.colorScheme(for: appearanceMode.rawValue)
    }

    func resolvedColorScheme(system: ColorScheme) -> ColorScheme {
        preferredColorScheme ?? system
    }

    private func sync() {
        AppearanceModeStore.updateSharedMode(storedMode)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
    }
}
