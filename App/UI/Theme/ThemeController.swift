import SwiftUI
import WidgetKit
import TenXShared

@MainActor
final class ThemeController: ObservableObject {
    private static let appearanceKey = UserDefaultsKeys.appearanceMode
    @Published private(set) var appearanceMode: AppearanceMode

    init() {
        let storedValue = Self.loadStoredMode()
        appearanceMode = AppearanceMode(rawValue: storedValue) ?? .system
        if storedValue != appearanceMode.rawValue {
            Self.storeMode(appearanceMode.rawValue)
        }
        sync()
    }

    func setAppearanceMode(_ mode: AppearanceMode, systemScheme: ColorScheme? = nil) {
        guard mode != appearanceMode else { return }
        appearanceMode = mode
        Self.storeMode(mode.rawValue)
        sync()
        AppIconManager.apply(for: mode, systemScheme: systemScheme)
    }

    var preferredColorScheme: ColorScheme? {
        AppAppearance.colorScheme(for: appearanceMode.rawValue)
    }

    func resolvedColorScheme(system: ColorScheme) -> ColorScheme {
        preferredColorScheme ?? system
    }

    private func sync() {
        AppearanceModeStore.updateSharedMode(appearanceMode.rawValue)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
    }

    private static func loadStoredMode() -> String {
        UserDefaults.standard.string(forKey: appearanceKey) ?? AppearanceMode.system.rawValue
    }

    private static func storeMode(_ value: String) {
        UserDefaults.standard.set(value, forKey: appearanceKey)
    }
}
