import Foundation
import TenXShared
import WidgetKit

@MainActor
final class ThemeManager: ObservableObject {
    @Published var theme: Theme {
        didSet { persistTheme() }
    }

    private let defaults: UserDefaults
    private let sharedDefaults: UserDefaults?

    init(defaults: UserDefaults = .standard,
         sharedDefaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupID)) {
        self.defaults = defaults
        self.sharedDefaults = sharedDefaults

        let rawValue = sharedDefaults?.string(forKey: UserDefaultsKeys.theme)
            ?? defaults.string(forKey: UserDefaultsKeys.theme)
        theme = Theme(rawValue: rawValue ?? Theme.midnight.rawValue) ?? .midnight
        persistTheme()
    }

    private func persistTheme() {
        defaults.set(theme.rawValue, forKey: UserDefaultsKeys.theme)
        sharedDefaults?.set(theme.rawValue, forKey: UserDefaultsKeys.theme)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
    }
}
