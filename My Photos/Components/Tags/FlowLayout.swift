import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity

        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0
        var isFirstInRow = true

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let itemWidth = size.width
            let itemHeight = size.height
            let additionalWidth = (isFirstInRow ? 0 : spacing) + itemWidth

            if currentRowWidth + additionalWidth > maxWidth {
                totalHeight +=
                    currentRowHeight + (totalHeight == 0 ? 0 : lineSpacing)

                maxRowWidth = max(maxRowWidth, currentRowWidth)
                currentRowWidth = itemWidth
                currentRowHeight = itemHeight
                isFirstInRow = false
            } else {
                currentRowWidth += additionalWidth

                currentRowHeight = max(currentRowHeight, itemHeight)
                isFirstInRow = false
            }
        }

        if currentRowWidth > 0 {
            totalHeight +=
                (totalHeight == 0 ? 0 : lineSpacing) + currentRowHeight
            maxRowWidth = max(maxRowWidth, currentRowWidth)
        }

        let finalWidth = proposal.width ?? maxRowWidth
        return CGSize(width: finalWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let maxWidth = bounds.width

        var rows: [[(index: Int, size: CGSize)]] = []
        var currentRow: [(index: Int, size: CGSize)] = []
        var currentRowWidth: CGFloat = 0
        var isFirstInRow = true

        for (index, subview) in subviews.enumerated() {
            var size = subview.sizeThatFits(.unspecified)
            size.width = min(size.width, maxWidth)  // Clamp oversized items

            let additionalWidth = (isFirstInRow ? 0 : spacing) + size.width

            if currentRowWidth + additionalWidth > maxWidth
                && !currentRow.isEmpty
            {
                rows.append(currentRow)

                currentRow = []
                currentRowWidth = 0
                isFirstInRow = true
            }

            if !currentRow.isEmpty { currentRowWidth += spacing }

            currentRow.append((index: index, size: size))
            currentRowWidth += size.width
            isFirstInRow = false
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { $0.size.height }.max() ?? 0
            var x = bounds.minX

            for item in row {
                let dx: CGFloat = 0
                let dy = (rowHeight - item.size.height) / 2

                subviews[item.index].place(
                    at: CGPoint(x: x + dx, y: y + dy),
                    proposal: ProposedViewSize(
                        width: item.size.width,
                        height: item.size.height
                    )
                )

                x += item.size.width + spacing
            }

            y += rowHeight + lineSpacing
        }
    }
}
