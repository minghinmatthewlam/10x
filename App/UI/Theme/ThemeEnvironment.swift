import SwiftUI
import TenXShared

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = Theme.midnight.palette
}

extension EnvironmentValues {
    var tenxTheme: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
