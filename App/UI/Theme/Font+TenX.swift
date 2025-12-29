import SwiftUI

extension Font {
    // Hero — large, impactful question prompts
    static var tenxHero: Font { .system(size: 32, weight: .medium) }

    // Title — section headers, date
    static var tenxTitle: Font { .system(size: 22, weight: .semibold) }

    // Large body — focus items, primary content
    static var tenxLargeBody: Font { .system(size: 19, weight: .regular) }

    // Body — standard content
    static var tenxBody: Font { .system(size: 17, weight: .regular) }

    // Small — secondary labels
    static var tenxSmall: Font { .system(size: 15, weight: .regular) }

    // Caption — metadata, hints
    static var tenxCaption: Font { .system(size: 13, weight: .medium) }
}
