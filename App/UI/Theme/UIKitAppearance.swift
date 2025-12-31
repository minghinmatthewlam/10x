import UIKit

enum UIKitAppearance {
    static func apply() {
        let normalFont = UIFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        let selectedFont = UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        let normalScaled = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: normalFont)
        let selectedScaled = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: selectedFont)

        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.setTitleTextAttributes([.font: normalScaled], for: .normal)
        segmentedControl.setTitleTextAttributes([.font: selectedScaled], for: .selected)
    }
}
