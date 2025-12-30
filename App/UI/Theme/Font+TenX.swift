import SwiftUI

enum TenXTypography {
    static let regularName: String? = nil
    static let mediumName: String? = nil
    static let semiboldName: String? = nil
    static let boldName: String? = nil
    static let systemDesign: Font.Design = .monospaced

    static func font(size: CGFloat, weight: Font.Weight, relativeTo: Font.TextStyle) -> Font {
        let name: String?
        switch weight {
        case .bold:
            name = boldName ?? semiboldName
        case .semibold:
            name = semiboldName
        case .medium:
            name = mediumName
        default:
            name = regularName
        }

        if let name {
            return .custom(name, size: size, relativeTo: relativeTo)
        }
        return .system(size: size, weight: weight, design: systemDesign)
    }
}

extension Font {
    // Display — branding + hero numerals
    static var tenxDisplay: Font { TenXTypography.font(size: 52, weight: .semibold, relativeTo: .largeTitle) }
    static var tenxDisplaySecondary: Font { TenXTypography.font(size: 46, weight: .semibold, relativeTo: .largeTitle) }
    static var tenxLogo: Font { TenXTypography.font(size: 48, weight: .semibold, relativeTo: .largeTitle) }
    static var tenxStat: Font { TenXTypography.font(size: 36, weight: .semibold, relativeTo: .title) }
    static var tenxShareBody: Font { TenXTypography.font(size: 26, weight: .regular, relativeTo: .title3) }

    // Hero — large, impactful question prompts
    static var tenxHero: Font { TenXTypography.font(size: 32, weight: .medium, relativeTo: .title) }

    // Title — section headers, date
    static var tenxTitle: Font { TenXTypography.font(size: 22, weight: .semibold, relativeTo: .title3) }

    // Large body — focus items, primary content
    static var tenxLargeBody: Font { TenXTypography.font(size: 19, weight: .regular, relativeTo: .body) }

    // Body — standard content
    static var tenxBody: Font { TenXTypography.font(size: 17, weight: .regular, relativeTo: .body) }

    // Small — secondary labels
    static var tenxSmall: Font { TenXTypography.font(size: 15, weight: .regular, relativeTo: .subheadline) }

    // Caption — metadata, hints
    static var tenxCaption: Font { TenXTypography.font(size: 13, weight: .medium, relativeTo: .caption) }

    // Micro — UI glyphs + small badges
    static var tenxMicroSemibold: Font { TenXTypography.font(size: 11, weight: .semibold, relativeTo: .caption2) }
    static var tenxTinySemibold: Font { TenXTypography.font(size: 12, weight: .semibold, relativeTo: .caption) }
    static var tenxTinyBold: Font { TenXTypography.font(size: 12, weight: .bold, relativeTo: .caption) }
    static var tenxIconSmall: Font { TenXTypography.font(size: 14, weight: .regular, relativeTo: .body) }
    static var tenxIconButton: Font { TenXTypography.font(size: 14, weight: .semibold, relativeTo: .body) }
    static var tenxIconMedium: Font { TenXTypography.font(size: 16, weight: .regular, relativeTo: .body) }
    static var tenxIconLarge: Font { TenXTypography.font(size: 36, weight: .regular, relativeTo: .title) }
}
