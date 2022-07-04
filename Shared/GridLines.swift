import SwiftUI

extension Path {
    /// Adds a horizontal line of the given height
    /// starting from the current point.
    mutating func addHLine(width: CGFloat) {
        guard let currentPoint = currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x + width,
                            y: currentPoint.y))
    }
    
    /// Adds a vertical line of the given width
    /// starting from the current point.
    mutating func addVLine(height: CGFloat) {
        guard let currentPoint = currentPoint else { return }
        addLine(to: CGPoint(x: currentPoint.x,
                            y: currentPoint.y + height))
    }
}

/// A shape that draws tic-tac-toe grid lines.
struct GridLines: Shape {
    /// The width of the lines.
    let lineWidth: Double
    
    /// The animation completion percentage of this grid.
    var animationCompletion: Double
    
    var animatableData: Double {
        get { animationCompletion }
        
        set { animationCompletion = newValue }
    }
    
    var body: some View {
        self.trim(from: 0, to: animationCompletion)
            .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
            .animation(.linear(duration: 1),
                       value: animationCompletion)
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
            // cellWidth = (rect.width - 2 * lineWidth) / 3
            // cellWidth + lineWidth = (rect.width + lineWidth) / 3
            let cellAndLineWidth = (rect.width + lineWidth) / 3
            for column in 1...2 {
                // Move the width of a cell and a line for
                // each column, then step back by half the
                // line width to draw at the gap's center.
                path.move(to: CGPoint(x: rect.minX + cellAndLineWidth * Double(column) - lineWidth / 2,
                                      y: rect.minY))
                path.addVLine(height: rect.height)
            }
            for row in 1...2 {
                // The same logic applies for the rows.
                // The cells are assumed to be square-shaped,
                // so the width is equal to the height.
                path.move(to: CGPoint(x: rect.minX,
                                      y: rect.minY + cellAndLineWidth * Double(row) - lineWidth / 2))
                path.addHLine(width: rect.width)
            }
        }
    }
}
