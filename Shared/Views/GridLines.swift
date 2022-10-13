import SwiftUI

extension Path {
    /// Adds a horizontal line of the given width,
    /// starting from the current point.
    mutating func addHLine(width: Double) {
        guard let currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x + width, y: currentPoint.y))
    }
    
    /// Adds a vertical line of the given height,
    /// starting from the current point.
    mutating func addVLine(height: Double) {
        guard let currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y + height))
    }
}

/// The grid lines of a tic-tac-toe grid.
struct GridLines : Shape {
    /// The stroke width of the grid lines.
    let lineWidth: Double
    
    /// The percentage drawn of each line.
    var animationPercentage: Double
    
    var animatableData: Double {
        get { animationPercentage }
        
        set { animationPercentage = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //     0   1   2
            //  0    |   |
            //    --- --- ---
            //  1    |   |
            //    --- --- ---
            //  2    |   |
            // The current offset from the origin point.
            var offset = (x: 0.0, y: 0.0)
            // The dimensions of the cells are calculated by removing the space
            // occupied by the lines and dividing the remaining by their count.
            let cellWidth = (rect.width - 2 * lineWidth) / 3
            let cellHeight = (rect.height - 2 * lineWidth) / 3
            for _ in 0..<2 {
                // Move to the center of the lines being drawn.
                offset.x += cellWidth + lineWidth / 2
                path.move(to: CGPoint(x: rect.minX + offset.x, y: rect.minY))
                // Animate this shape by drawing a percentage of the lines
                // according to the completion percentage of the animation.
                path.addVLine(height: animationPercentage * rect.height)
                offset.y += cellHeight + lineWidth / 2
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + offset.y))
                path.addHLine(width: animationPercentage * rect.width)
                // Move to the start of the next cell.
                offset.x += lineWidth / 2
                offset.y += lineWidth / 2
            }
        }
        .strokedPath(StrokeStyle(lineWidth: lineWidth))
    }
}
