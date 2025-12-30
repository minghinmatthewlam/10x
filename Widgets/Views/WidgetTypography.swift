import SwiftUI

enum WidgetTypography {
    private static func font(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static let logo = font(size: 16, weight: .semibold)
    static let title = font(size: 15, weight: .semibold)
    static let badge = font(size: 11, weight: .semibold)
    static let body = font(size: 12, weight: .regular)
    static let caption = font(size: 11, weight: .medium)
    static let progress = font(size: 12, weight: .medium)
}
