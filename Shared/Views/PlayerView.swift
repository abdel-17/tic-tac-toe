import SwiftUI

struct PlayerView : Shape {
    /// The duration of the player's drawing
    /// animation in nanoseconds.
    static let animationDurationNano: UInt64 = 500_000_000
    
    /// The animation used to draw players.
    static let animation = Animation.easeOut(duration: 0.5)
    
    /// The player drawn by this view, if any.
    let player: TicTacToe.Player?
    
    /// The stroke width of the drawing line.
    let lineWidth: Double
    
    /// The completion percentage of the
    /// player's drawing animation.
    var animationCompletion: Double
    
    var animatableData: Double {
        get { animationCompletion }
        
        set { animationCompletion = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Draw nothing if the cell is empty.
            guard let player else { return }
            // Add 15% padding.
            let rect = rect.insetBy(dx: 0.15 * rect.width, dy: 0.15 * rect.height)
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
                            radius: min(rect.width, rect.height) / 2,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false)
            }
        }
        // Draw a portion of the path according to the animation.
        .trimmedPath(from: 0, to: animationCompletion)
        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
}
