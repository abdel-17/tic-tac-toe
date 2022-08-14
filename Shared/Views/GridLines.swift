import SwiftUI

fileprivate extension Path {
    /// Adds a horizontal line having width,
    /// starting from the current point.
    mutating func addHLine(width: Double) {
        guard let currentPoint = currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x + width, y: currentPoint.y))
    }
    
    /// Adds a vertical line of the given height,
    /// starting from the current point.
    mutating func addVLine(height: Double) {
        guard let currentPoint = currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y + height))
    }
}

/// A shape that draws tic-tac-toe grid lines.
struct GridLines: Shape {
    /// The width of the lines.
    let lineWidth: Double
    
    /// The completion percentage of the animation.
    var animationProgress: Double
    
    var animatableData: Double {
        get { animationProgress }
        
        set { animationProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //     0   1   2
            //  0    |   |
            //    -----------
            //  1    |   |
            //    -----------
            //  2    |   |
            //
            // We assume the cells are square-shaped.
            // Move the width of a cell and a line for
            // each row/column, then step back by half
            // the line width to draw at the gap's center.
            //
            // cellWidth = (rect.width - 2 * lineWidth) / 3
            // cellWidth + lineWidth
            let totalWidth = (rect.width + lineWidth) / 3
            for i in 1...2 {
                let offset = Double(i) * totalWidth - lineWidth / 2
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + offset))
                path.addHLine(width: animationProgress * rect.width)
                path.move(to: CGPoint(x: rect.minX + offset, y: rect.minY))
                path.addVLine(height: animationProgress * rect.height)
            }
        }
        .strokedPath(StrokeStyle(lineWidth: lineWidth))
    }
}
