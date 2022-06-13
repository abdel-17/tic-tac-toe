import SwiftUI

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
    
    typealias Line = (start: CGPoint, end: CGPoint)
    
    /// Draws each of the given lines consecutively.
    ///
    /// Each line in the array is drawn partially (or completely)
    /// according to the given percentage. For example,
    /// if we want to draw two lines, `0...0.5` is the
    /// range in which the first line is drawn, and `0.5...1`
    /// is the range in which both are drawn.
    ///
    /// - Parameters:
    ///   - path: The path to draw in.
    ///   - lines: The lines to draw.
    ///   - completionPercentage: The completion
    ///   percentage of the drawing. `0` means no lines are
    ///   drawn and `1` means all the lines are drawn.
    static func draw(in path: inout Path,
                     lines: [Line],
                     completionPercentage: Double) {
        assert((0...1).contains(completionPercentage))
        let count = Double(lines.count)
        for (index, line) in lines.enumerated() {
            // The subintervlas are divided into:
            // 0...1/count,
            // 1/count...2/count,
            // and so on until (count-1)/count...1.
            let minThreshold = Double(index) / count
            // Negative percentages imply the line is not
            // to be drawn yet.
            guard completionPercentage > minThreshold else { return }
            // First, we calculate the difference between the
            // percentage and the subinterval's lower bound,
            // then we find its ratio to the width of the
            // subinterval, which is 1/count.
            let ratio = count * (completionPercentage - minThreshold)
            let percentageDrawn = min(ratio, 1)
            let (start, end) = line
            path.move(to: start)
            // x = start.x + (end.x - start.x) * percentageDrawn
            // Same formula for y.
            path.addLine(to: CGPoint(x: (1 - percentageDrawn) * start.x + percentageDrawn * end.x,
                                     y: (1 - percentageDrawn) * start.y + percentageDrawn * end.y))
        }
        
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //     [0] [1] [2]
            // [0]    |   |
            //     -----------
            // [1]    |   |
            //     -----------
            // [2]    |   |
            let cellLength = (rect.width - 2 * lineWidth) / 3
            var lines: [Line] = []
            for column in 1...2 {
                // Move the width of a cell and a line for
                // each column, then step back by half the
                // line's width to draw at its center.
                let x = rect.minX + Double(column) * (cellLength + lineWidth) - 0.5 * lineWidth
                lines.append((CGPoint(x: x, y: rect.minY),
                              CGPoint(x: x, y: rect.maxY)))
            }
            for row in 1...2 {
                // The same logic above applies here.
                let y = rect.minY + Double(row) * (cellLength + lineWidth) - 0.5 * lineWidth
                lines.append((CGPoint(x: rect.minX, y: y),
                              CGPoint(x: rect.maxX, y: y)))
            }
            GridLines.draw(in: &path,
                           lines: lines,
                           completionPercentage: animationCompletion)
        }
    }
}
