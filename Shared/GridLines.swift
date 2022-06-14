import SwiftUI

extension Path {
    /// Draws a percentage of the line having the given end-points.
    ///
    /// - Parameters:
    ///   - start: The point from which the line is drawn.
    ///   - end: The end-point of the line.
    ///   - percentage: The percentage of the line to draw.
    mutating func addLine(from start: CGPoint, to end: CGPoint, percentage: Double) {
        assert((0...1).contains(percentage))
        move(to: start)
        // x = start.x + (end.x - start.x) * percentage
        // Same formula for y.
        addLine(to: CGPoint(x: (1 - percentage) * start.x + percentage * end.x,
                            y: (1 - percentage) * start.y + percentage * end.y))
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
        self.stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //     [0] [1] [2]
            // [0]    |   |
            //     -----------
            // [1]    |   |
            //     -----------
            // [2]    |   |
            //
            // cellWidth = (rect.width - 2 * lineWidth) / 3
            // cellWidth + lineWidth = (rect.width + lineWidth) / 3
            let cellAndLineWidth = (rect.width + lineWidth) / 3
            // The first line is drawn when animationCompletion is
            // in 0...25%, the second line in 25%...50%, and so on.
            // We calculate the difference between animationCompletion
            // and the subinterval's lower bound. If the difference is
            // negative, we stop drawing. Otherwise, the percentage drawn
            // is the ratio between that difference and the width of the
            // subinterval (in this case, it's 25%). To make sure that the
            // percentage does not exceed 1 after the line is completely
            // drawn, we apply the min function.
            var minThreshold = 0.0
            func percentageDrawn() -> Double? {
                let difference = animationCompletion - minThreshold
                guard difference > 0 else { return nil }
                minThreshold += 0.25
                return min(4 * difference, 1)
            }
            for column in 1...2 {
                guard let percentage = percentageDrawn() else { return }
                // Move the width of a cell and a line for
                // each column, then step back by half the
                // line width to draw at the gap's center.
                let x = rect.minX + cellAndLineWidth * Double(column) - lineWidth / 2
                path.addLine(from: CGPoint(x: x, y: rect.minY),
                             to: CGPoint(x: x, y: rect.maxY),
                             percentage: percentage)
            }
            for row in 1...2 {
                guard let percentage = percentageDrawn() else { return }
                // The same logic applies for the rows as
                // the cells are assumed to be square-shaped.
                let y = rect.minY + cellAndLineWidth * Double(row) - lineWidth / 2
                path.addLine(from: CGPoint(x: rect.minX, y: y),
                             to: CGPoint(x: rect.maxX, y: y),
                             percentage: percentage)
            }
        }
    }
}
