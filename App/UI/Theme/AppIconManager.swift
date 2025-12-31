import SwiftUI
import UIKit

enum AppIconManager {
    static let darkIconName = "AppIconDark"

    static func apply(for mode: AppearanceMode, systemScheme: ColorScheme? = nil) {
        let desiredName = desiredIconName(for: mode, systemScheme: systemScheme)
        setAlternateIconIfNeeded(desiredName)
    }

    private static func desiredIconName(for mode: AppearanceMode, systemScheme: ColorScheme?) -> String? {
        switch mode {
        case .light:
            return nil
        case .dark:
            return darkIconName
        case .system:
            return (systemScheme == .dark) ? darkIconName : nil
        }
    }

    private static func setAlternateIconIfNeeded(_ name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        guard UIApplication.shared.alternateIconName != name else { return }
        UIApplication.shared.setAlternateIconName(name)
    }
}
