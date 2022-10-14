import SwiftUI

/// A button in a tic-tac-toe grid.
struct GridButton : View {
    /// The completion percentage of the player's
    /// drawing animation.
    @State private var animationCompletion = 0.0
    
    /// The cell this button is positioned at in the grid.
    let cell: TicTacToe.Cell
    
    /// The stroke width of the drawing line.
    let lineWidth: Double
    
    /// A publisher for receiving reset events.
    let resetPublisher: EventPublisher
    
    /// The action performed when this button is clicked.
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            PlayerView(player: cell.player,
                       lineWidth: lineWidth,
                       animationCompletion: animationCompletion)
        }
        .buttonStyle(.borderless)
        .foregroundColor(foregroundColor)
        // Animate the color transition to green.
        .animation(PlayerView.animation, value: cell.isMatching)
        // Animate the drawing of players.
        .animation(PlayerView.animation, value: animationCompletion)
        .onChange(of: cell.player) { player in
            // Animate drawing the player.
            if player != nil { animationCompletion = 1 }
        }
        .onReceive(resetPublisher) {
            animationCompletion = 0
        }
    }
    
    private var foregroundColor: Color? {
        // Mark matching cells with a green color.
        guard !cell.isMatching else { return .green }
        switch cell.player {
        case .x:
            // X is given a red color. Fitting for a cross, isn't it?
            return .red
        case .o:
            // Blue is complementary to red.
            return .blue
        case nil:
            return nil
        }
    }
}
