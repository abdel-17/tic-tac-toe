import SwiftUI

/// A square-like shape that draws a tic-tac-toe player.
struct Cell: Shape {
    @ObservedObject var model: ViewModel
    
    /// The index of this cell according to row-major order.
    let index: Int
    
    /// The width of the drawing line.
    let lineWidth: CGFloat
    
    /// The animation completion percentage of this cell.
    var animationCompletion: Double
    
    init(model: ViewModel, index: Int, lineWidth: CGFloat) {
        self.model = model
        self.index = index
        self.lineWidth = lineWidth
        self.animationCompletion = model.animationCompletions[index]
    }
    
    /// The duration of a cell's animation.
    static var animationDuration: Double { 0.5 }
    
    /// The animation performed by a cell.
    static var animation: Animation {
        .easeOut(duration: animationDuration)
    }
    
    var animatableData: Double {
        get { animationCompletion }
        
        set { animationCompletion = newValue }
    }
    
    var body: some View {
        // Stroke with a rounded line of the given width.
        self.stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
            .foregroundColor(foregroundColor)
            .aspectRatio(1, contentMode: .fit)
            .animation(Cell.animation, value: isMatching)
    }
    
    /// The player at this cell.
    private var player: TicTacToe.Player? {
        model.game.grid[index]
    }
    
    /// A Boolean value to check if this cell is matching.
    private var isMatching: Bool {
        model.game.isMatching(at: index)
    }
    
    /// The foreground color of this cell.
    private var foregroundColor: Color? {
        if isMatching {
            return .green
        }
        switch player {
        case .x:
            return .red
        case .o:
            return .blue
        case nil:
            return nil
        }
    }
    
    func path(in rect: CGRect) -> Path {
        // Draw nothing if the cell is empty.
        guard let player = player else {
            return Path()
        }
        // Add 20% padding.
        let rect = rect.insetBy(dx: 0.2 * rect.width,
                                dy: 0.2 * rect.height)
        return Path { path in
            switch player {
            case .x:
                // We first draw a line from the upper left corner
                // to the lower right corner completely, then after
                // that's done, we draw the other diagonal line.
                let upperLeft = CGPoint(x: rect.minX, y: rect.minY)
                let upperRight = CGPoint(x: rect.maxX, y: rect.minY)
                let lowerLeft = CGPoint(x: rect.minX, y: rect.maxY)
                let lowerRight = CGPoint(x: rect.maxX, y: rect.maxY)
                GridLines.draw(in: &path,
                               lines: [(upperLeft, lowerRight),
                                       (upperRight, lowerLeft)],
                               completionPercentage: animationCompletion)
            case .o:
                // Draw a centered arc from 0° to 360° * (animation)%.
                path.addArc(center: CGPoint(x: rect.midX,
                                            y: rect.midY),
                            radius: rect.width / 2,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * animationCompletion),
                            clockwise: false)
            }
        }
    }
}
