import SwiftUI

/// A shape that draws a tic-tac-toe player in a square.
struct Cell: Shape {
    /// The duration of a cell's animation.
    static var animationDuration: Double { 0.5 }
    
    /// The animation performed by a cell.
    static var animation: Animation {
        .easeOut(duration: animationDuration)
    }
    
    /// The player at this cell.
    let player: TicTacToe.Player?
    
    /// A Boolean value to check if the player at this cell
    /// is matching along any of the 4 directions.
    let isMatching: Bool
    
    /// The width of the drawing line.
    let lineWidth: Double
    
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
            .animation(Cell.animation, value: isMatching)
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
