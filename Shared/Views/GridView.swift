import SwiftUI

/// A view that displays a tic-tac-toe grid.
struct GridView: View {
    /// The animation progress of the grid lines.
    @State private var animationProgress = 0.0
    
    @EnvironmentObject var grid: GameGrid
    
    /// The side length of the grid.
    let length: Double
    
    /// The width of the drawing line.
    private var lineWidth: Double {
        0.025 * length
    }
    
    var body: some View {
        VStack(spacing: lineWidth) {
            ForEach(0..<3) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3) { column in
                        GridButton(index: 3 * row + column,
                                   lineWidth: lineWidth)
                    }
                }
            }
        }
        .background(GridLines(lineWidth: lineWidth,
                              animationProgress: animationProgress))
        .frame(width: length, height: length)
        .disabled(grid.isDisabled)
        .task {
            // Animate the grid lines when the grid appears.
            // Slightly delay the animation to account
            // for app-start animation.
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
                animationProgress = 1.0
            }
            await Task.sleep(seconds: 0.75)
        }
    }
}
