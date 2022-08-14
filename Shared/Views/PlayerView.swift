import SwiftUI

/// A shape that draws a tic-tac-toe player.
struct PlayerView: Shape {
    /// The duration of the animation used by this type.
    static let animationDuration = 0.5
    
    /// The animation used to draw players.
    static let animation = Animation.easeOut(duration: PlayerView.animationDuration)
    
    /// The cell this view presents.
    let player: TicTacToe.Player?
    
    /// The width of the drawing line.
    let lineWidth: Double
    
    /// The completion percentage of the animation.
    var animationProgress: Double
    
    var animatableData: Double {
        get { animationProgress }
        
        set { animationProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Draw nothing if the cell is empty.
            guard let player = player else { return }
            // 20% padding
            let rect = rect.insetBy(dx: 0.2 * rect.width, dy: 0.2 * rect.height)
            switch player {
            case .x:
                // Draw a diagonal from the upper left corner.
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                // Draw a diagonal from the upper right corner.
                path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            case .o:
                // Draw a centered arc.
                path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                            radius: rect.width / 2,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false)
            }
        }
        .trimmedPath(from: 0, to: animationProgress)
        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}
