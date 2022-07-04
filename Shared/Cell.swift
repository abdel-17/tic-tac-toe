import SwiftUI

/// A shape that draws a tic-tac-toe player.
struct Cell: Shape {
    /// The duration of a cell's animation.
    static let animationDuration = 0.5
    
    /// The animation used to draw the players.
    static let animation = Animation.easeOut(duration: Cell.animationDuration)
    
    /// The player at this cell.
    let player: TicTacToe.Player?
    
    /// The width of the drawing line.
    let lineWidth: Double
    
    /// True iff this cell is at a matching position.
    let isMatching: Bool
    
    /// The animation completion percentage of this cell.
    var animationCompletion: Double
    
    var animatableData: Double {
        get { animationCompletion }
        
        set { animationCompletion = newValue }
    }
    
    var body: some View {
        self.trim(from: 0, to: animationCompletion)
            .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
            .foregroundColor(foregroundColor)
            .animation(.default, value: isMatching)
    }
    
    /// The foreground color of this cell.
    private var foregroundColor: Color? {
        guard !isMatching else { return .green }
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
        Path { path in
            // Draw nothing if the cell is empty.
            guard let player = player else { return }
            // Add 10% padding around each edge.
            let rect = rect.insetBy(dx: 0.2 * rect.width,
                                    dy: 0.2 * rect.height)
            switch player {
            case .x:
                // Draw two diagonal lines.
                let upperLeft = CGPoint(x: rect.minX,
                                        y: rect.minY)
                let lowerRight = CGPoint(x: rect.maxX,
                                         y: rect.maxY)
                path.move(to: upperLeft)
                path.addLine(to: lowerRight)
                let upperRight = CGPoint(x: rect.maxX,
                                         y: rect.minY)
                let lowerLeft = CGPoint(x: rect.minX,
                                        y: rect.maxY)
                path.move(to: upperRight)
                path.addLine(to: lowerLeft)
            case .o:
                // Draw a centered arc.
                path.addArc(center: CGPoint(x: rect.midX,
                                            y: rect.midY),
                            radius: rect.width / 2,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false)
            }
        }
    }
}
