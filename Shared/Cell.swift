import SwiftUI

/// A shape that draws a tic-tac-toe player.
struct Cell: Shape {
    /// The player at this cell.
    let player: TicTacToeGrid.Player?
    
    /// The width of the drawing line.
    let lineWidth: CGFloat
    
    /// The completion percentage of
    /// this cell's animation.
    var animationCompletion: Double
    
    var animatableData: Double {
        // Animate changes to the completion percentage.
        get { animationCompletion }
        
        set { animationCompletion = newValue }
    }
    
    var body: some View {
        // Stroke with a rounded line of the given width.
        self.stroke(style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round))
    }
    
    func path(in rect: CGRect) -> Path {
        // Draw on 80% of the inner space.
        let insetRect = rect.insetBy(dx: 0.2 * rect.width,
                                     dy: 0.2 * rect.height)
        return Path { path in
            switch player {
            case .x:
                /// Draws a percentage of the line from the upper
                /// corner of the cell to its lower corner.
                func drawLine(startX: CGFloat, endX: CGFloat, percentage: CGFloat) {
                    // Start drawing from the top of the rectangle...
                    let start = CGPoint(x: startX, y: insetRect.minY)
                    let end = start.applying(
                        // ...to the bottom.
                        CGAffineTransform(translationX: percentage * (endX - startX),
                                          y: percentage * insetRect.height)
                    )
                    path.move(to: start)
                    path.addLine(to: end)
                }
                // We first draw the line from the upper left
                // corner completely, then start drawing the
                // upper right corner line. 50% marks the end
                // of this animation, so its completion after
                // stays fixed at 100%. If animation completion
                // is 0%, a point is drawn, so we check for that.
                if animationCompletion > 0 {
                    drawLine(startX: insetRect.minX,
                             endX: insetRect.maxX,
                             percentage: min(2 * animationCompletion, 1))
                }
                // Draw the upper right corner line only after 50%.
                if animationCompletion >= 0.5 {
                    drawLine(startX: insetRect.maxX,
                             endX: insetRect.minX,
                             percentage: 2 * animationCompletion - 1)
                }
            case .o:
                // Draw a centered arc from 0 to 360 * (animation)% degrees.
                path.addArc(center: CGPoint(x: insetRect.midX, y: insetRect.midY),
                            radius: insetRect.width / 2,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * animationCompletion),
                            clockwise: false)
                //path.closeSubpath()
            case nil:
                // Empty cell. Draw nothing.
                break
            }
        }
    }
}

struct CellPreviews: PreviewProvider {
    /// A view to test the animation of the cell.
    struct AnimationPreview: View {
        @State var animationPercentage = 0.0
        
        var body: some View {
            VStack {
                HStack {
                    ForEach([.x, .o] as [TicTacToeGrid.Player],
                            id: \.self) { player in
                        Cell(player: player,
                             lineWidth: 5,
                             animationCompletion: animationPercentage)
                        .aspectRatio(contentMode: .fit)
                    }
                }

                Button("Start Animation") {
                    withAnimation(
                        .easeInOut(duration: 1)
                        .repeatForever(autoreverses: true)) {
                        animationPercentage = 1
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        AnimationPreview()
            .padding()
    }
}

