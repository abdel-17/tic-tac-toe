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
        self.trim(from: 0, to: animationCompletion)
            .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
            .animation(.linear(duration: 1),
                       value: animationCompletion)
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
            for column in 1...2 {
                // Move the width of a cell and a line for
                // each column, then step back by half the
                // line width to draw at the gap's center.
                let x = rect.minX + cellAndLineWidth * Double(column) - lineWidth / 2
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
            }
            for row in 1...2 {
                // The same logic applies for the rows.
                // The cells are assumed to be square-shaped,
                // so the width is equal to the height.
                let y = rect.minY + cellAndLineWidth * Double(row) - lineWidth / 2
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
        }
    }
}
