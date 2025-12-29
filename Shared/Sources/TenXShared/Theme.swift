import Foundation
import SwiftUI

public struct ThemePalette: Equatable {
    public let background: Color
    public let surface: Color
    public let accent: Color
    public let complete: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let textMuted: Color
    public let card: Color

    public init(background: Color,
                surface: Color,
                accent: Color,
                complete: Color,
                textPrimary: Color,
                textSecondary: Color,
                textMuted: Color,
                card: Color) {
        self.background = background
        self.surface = surface
        self.accent = accent
        self.complete = complete
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textMuted = textMuted
        self.card = card
    }
}

public enum Theme: String, CaseIterable, Identifiable {
    case midnight
    case dawn
    case sand
    case forest
    case slate
    case mist

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .midnight: return "Midnight"
        case .dawn: return "Dawn"
        case .sand: return "Sand"
        case .forest: return "Forest"
        case .slate: return "Slate"
        case .mist: return "Mist"
        }
    }

    public var palette: ThemePalette {
        switch self {
        case .midnight:
            return ThemePalette(
                background: Color(hex: "09090B"),
                surface: Color(hex: "18181B"),
                accent: Color(hex: "FAFAF9"),
                complete: Color(hex: "A1A1AA"),
                textPrimary: Color(hex: "FAFAF9"),
                textSecondary: Color(hex: "71717A"),
                textMuted: Color(hex: "3F3F46"),
                card: Color(hex: "18181B")
            )
        case .dawn:
            return ThemePalette(
                background: Color(hex: "140B0B"),
                surface: Color(hex: "241514"),
                accent: Color(hex: "FBEDE6"),
                complete: Color(hex: "E2B8A8"),
                textPrimary: Color(hex: "FBEDE6"),
                textSecondary: Color(hex: "C5A8A1"),
                textMuted: Color(hex: "6C4E4E"),
                card: Color(hex: "241514")
            )
        case .sand:
            return ThemePalette(
                background: Color(hex: "14120E"),
                surface: Color(hex: "26211B"),
                accent: Color(hex: "F7F1E6"),
                complete: Color(hex: "C9BBA2"),
                textPrimary: Color(hex: "F7F1E6"),
                textSecondary: Color(hex: "B7AFA2"),
                textMuted: Color(hex: "6E6352"),
                card: Color(hex: "26211B")
            )
        case .forest:
            return ThemePalette(
                background: Color(hex: "0B1210"),
                surface: Color(hex: "16201B"),
                accent: Color(hex: "E6F2EC"),
                complete: Color(hex: "9CC2AE"),
                textPrimary: Color(hex: "E6F2EC"),
                textSecondary: Color(hex: "9BB3A8"),
                textMuted: Color(hex: "4B5F57"),
                card: Color(hex: "16201B")
            )
        case .slate:
            return ThemePalette(
                background: Color(hex: "0C1014"),
                surface: Color(hex: "1A2027"),
                accent: Color(hex: "EAF2FA"),
                complete: Color(hex: "A7B4C2"),
                textPrimary: Color(hex: "EAF2FA"),
                textSecondary: Color(hex: "98A6B5"),
                textMuted: Color(hex: "4B5A66"),
                card: Color(hex: "1A2027")
            )
        case .mist:
            return ThemePalette(
                background: Color(hex: "0F1115"),
                surface: Color(hex: "1C2028"),
                accent: Color(hex: "F0F3F8"),
                complete: Color(hex: "B9C3D1"),
                textPrimary: Color(hex: "F0F3F8"),
                textSecondary: Color(hex: "9BA7B7"),
                textMuted: Color(hex: "4D5663"),
                card: Color(hex: "1C2028")
            )
        }
    }
}

public enum ThemeStore {
    public static func storedTheme(userDefaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupID)) -> Theme? {
        guard let raw = userDefaults?.string(forKey: SharedConstants.themeKey),
              let theme = Theme(rawValue: raw) else {
            return nil
        }
        return theme
    }

    public static func currentTheme(userDefaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupID),
                                    fallback: Theme = .midnight) -> Theme {
        guard let raw = userDefaults?.string(forKey: SharedConstants.themeKey),
              let theme = Theme(rawValue: raw) else {
            return fallback
        }
        return theme
    }
}
