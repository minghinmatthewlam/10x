import SwiftUI

public struct YearProgressDotGrid: View {
    public let colors: [Color]
    public let inset: CGFloat
    public let spacingXMin: CGFloat
    public let spacingYMin: CGFloat
    public let minColumns: Int
    public let maxColumns: Int

    public init(colors: [Color],
                inset: CGFloat,
                spacingXMin: CGFloat,
                spacingYMin: CGFloat,
                minColumns: Int,
                maxColumns: Int) {
        self.colors = colors
        self.inset = inset
        self.spacingXMin = spacingXMin
        self.spacingYMin = spacingYMin
        self.minColumns = minColumns
        self.maxColumns = maxColumns
    }

    public var body: some View {
        GeometryReader { proxy in
            let availableSize = CGSize(width: max(0, proxy.size.width - inset * 2),
                                       height: max(0, proxy.size.height - inset * 2))
            let layout = YearProgressGridLayout.layout(
                for: availableSize,
                totalDays: colors.count,
                spacingX: spacingXMin,
                spacingYMin: spacingYMin,
                minColumns: minColumns,
                maxColumns: maxColumns
            )
            let spacingX = layout.columns > 1
                ? max(spacingXMin,
                      (availableSize.width - CGFloat(layout.columns) * layout.dotSize) / CGFloat(layout.columns - 1))
                : 0
            let gridItems = Array(repeating: GridItem(.fixed(layout.dotSize), spacing: spacingX), count: layout.columns)

            LazyVGrid(columns: gridItems, spacing: layout.spacingY) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: layout.dotSize, height: layout.dotSize)
                }
            }
            .frame(width: availableSize.width, height: availableSize.height, alignment: .topLeading)
            .padding(inset)
        }
    }
}
