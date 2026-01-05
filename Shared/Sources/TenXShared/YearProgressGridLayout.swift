import SwiftUI

public enum YearProgressGridLayout {
    public static func layout(
        for size: CGSize,
        totalDays: Int,
        spacingX: CGFloat,
        spacingYMin: CGFloat,
        minColumns: Int = 10,
        maxColumns: Int = 20
    ) -> (columns: Int, dotSize: CGFloat, spacingY: CGFloat) {
        guard totalDays > 0 else { return (columns: 1, dotSize: 4, spacingY: spacingYMin) }

        var bestColumns = minColumns
        var bestDotSize: CGFloat = 0
        var bestSpacingY: CGFloat = spacingYMin

        for columns in minColumns...maxColumns {
            let rows = Int(ceil(Double(totalDays) / Double(columns)))
            guard rows > 0 else { continue }
            let widthDot = (size.width - spacingX * CGFloat(columns - 1)) / CGFloat(columns)
            let heightDot = (size.height - spacingYMin * CGFloat(rows - 1)) / CGFloat(rows)
            let rawDot = min(widthDot, heightDot)
            let dotSize = max(2, floor(rawDot))
            let totalDotHeight = CGFloat(rows) * dotSize
            let availableSpacing = max(0, size.height - totalDotHeight)
            let spacingY = rows > 1 ? max(spacingYMin, availableSpacing / CGFloat(rows - 1)) : 0

            if dotSize > bestDotSize {
                bestDotSize = dotSize
                bestColumns = columns
                bestSpacingY = spacingY
            }
        }

        return (columns: bestColumns, dotSize: bestDotSize, spacingY: bestSpacingY)
    }
}
