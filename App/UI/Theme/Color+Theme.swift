import SwiftUI

extension Color {
    // Warm, near-black backgrounds
    static let tenxBackground = Color(hex: "09090B")
    static let tenxSurface = Color(hex: "18181B")

    // Warm ivory accent — sophisticated, not aggressive
    static let tenxAccent = Color(hex: "FAFAF9")

    // Subtle completion state
    static let tenxComplete = Color(hex: "A1A1AA")

    // Text hierarchy
    static let tenxTextPrimary = Color(hex: "FAFAF9")
    static let tenxTextSecondary = Color(hex: "71717A")
    static let tenxTextMuted = Color(hex: "3F3F46")

    // Legacy alias for existing code
    static let tenxCard = tenxSurface
}
