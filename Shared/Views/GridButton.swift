import SwiftUI

/// A button in a tic-tac-toe grid.
struct GridButton: View {
    @AppStorage("difficulty") var difficulty = TicTacToe.Difficulty.medium
    
    @EnvironmentObject var grid: GameGrid
    
    /// The row-major index of this button in the grid.
    let index: Int
    
    /// The width of the drawing line.
    let lineWidth: Double
    
    var body: some View {
        Button {
            Task {
                guard grid.game.hasNotEnded else {
                    // Reset after the game ends.
                    await grid.reset()
                    return
                }
                await grid.play(at: index, difficulty: difficulty)
            }
        } label: {
            PlayerView(player: cell.player,
                       lineWidth: lineWidth,
                       animationProgress: animationProgress)
        }
        .buttonStyle(.borderless)
        .foregroundColor(foregroundColor)
        // Animate the color transition to green.
        .animation(PlayerView.animation, value: cell.isMatching)
        // Prevent playing at occupied cells during the game.
        .disabled(!cell.isEmpty && grid.game.hasNotEnded)
    }
    
    /// The cell at the index of this button.
    private var cell: TicTacToe.Cell {
        grid.game.cells[index]
    }
    
    /// The animation progress of the cell
    /// at this button's index.
    private var animationProgress: Double {
        grid.cellsAnimationProgress[index]
    }
    
    /// The foreground color of this button.
    private var foregroundColor: Color? {
        // Mark matching cells.
        guard !cell.isMatching else { return .green }
        switch cell.player {
        case .x:
            return .red
        case .o:
            return .blue
        case nil:
            return nil
        }
    }
}
