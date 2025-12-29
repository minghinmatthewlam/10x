import SwiftUI
import TenXShared

extension Color {
    // Warm, near-black backgrounds
    static let tenxBackground = Theme.midnight.palette.background
    static let tenxSurface = Theme.midnight.palette.surface

    // Warm ivory accent — sophisticated, not aggressive
    static let tenxAccent = Theme.midnight.palette.accent

    // Subtle completion state
    static let tenxComplete = Theme.midnight.palette.complete

    // Text hierarchy
    static let tenxTextPrimary = Theme.midnight.palette.textPrimary
    static let tenxTextSecondary = Theme.midnight.palette.textSecondary
    static let tenxTextMuted = Theme.midnight.palette.textMuted

    // Legacy alias for existing code
    static let tenxCard = tenxSurface
}
