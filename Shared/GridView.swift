import SwiftUI

/// A 3x3 grid of evenly-spaced cells.
struct GridView: View {
    @ObservedObject var model: ViewModel
    
    /// The width of the drawing line.
    let lineWidth: Double
    
    var body: some View {
        VStack(spacing: lineWidth) {
            ForEach(0..<3) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3) { column in
                        let index = 3 * row + column
                        Button {
                            Task {
                                guard !model.game.hasEnded else {
                                    await model.startNewGame()
                                    return
                                }
                                await model.play(at: index)
                            }
                        } label: {
                            Cell(player: model.game.grid[index],
                                 isMatching: model.game.isMatching(at: index),
                                 lineWidth: lineWidth,
                                 animationCompletion: model.cellAnimationCompletions[index])
                        }
                        .buttonStyle(.borderless)
                        .disabled(!model.game.isEmpty(at: index) &&
                                  !model.game.hasEnded)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(GridLines(lineWidth: lineWidth,
                              animationCompletion: model.gridAnimationCompletion))
        .task {
            await model.startGridAnimation()
        }
        .disabled(model.isAnimating)
        #if os(macOS)
        .frame(minWidth: 300)
        #endif
    }
}
