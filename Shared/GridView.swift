import SwiftUI

/// A 3x3 grid of evenly-spaced cells.
struct GridView: View {
    @ObservedObject var model: ViewModel
    
    /// The width of the drawing line
    let lineWidth: Double
    
    /// The animation completion percentage of the grid.
    @State private var animationCompletion = 0.0
    
    var body: some View {
        VStack(spacing: lineWidth) {
            ForEach(0..<3) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3) { column in
                        let index = 3 * row + column
                        Button {
                            guard !model.game.hasEnded else {
                                model.startNewGame()
                                return
                            }
                            model.play(at: index)
                        } label: {
                            Cell(model: model,
                                 index: 3 * row + column,
                                 lineWidth: lineWidth)
                        }
                        .disabled(!model.game.isEmpty(at: index) &&
                                  !model.game.hasEnded)
                    }
                }
            }
        }
        .background(GridLines(lineWidth: lineWidth,
                              animationCompletion: animationCompletion))
        .onAppear {
            withAnimation(.linear(duration: 1.0)) {
                animationCompletion = 1
            }
        }
        .disabled(model.isAnimating)
    }
}
