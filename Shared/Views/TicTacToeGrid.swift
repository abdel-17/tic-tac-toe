import SwiftUI

struct TicTacToeGrid : View {
    /// A Boolean value equal to `true`
    /// when the opponent is the AI.
    @AppStorage("isPVE") private var isPVE = true
    
    /// The difficulty level of the AI.
    @AppStorage("difficulty") private var difficulty = TicTacToe.Difficulty.medium
 
    /// Contains the logic of the game.
    @State private var game = TicTacToe(startingPlayer: .x)
    
    /// A Boolean value to disable the grid.
    ///
    /// This is used to avoid invalid UI state.
    /// For example, playing during the AI's turn.
    @State private var isDisabled = true
    
    /// The percentage of the grid lines drawn.
    @State private var animationCompletion = 0.0
    
    /// The text presented by the navigation bar.
    @Binding var navigationTitle: String
    
    /// A publisher for receiving reset events.
    let resetPublisher: EventPublisher
    
    /// The side length of the grid.
    let length: Double
    
    var body: some View {
        let lineWidth = 0.025 * length
        VStack(spacing: lineWidth) {
            ForEach(0..<3) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3) { column in
                        let index = game.index(row: row, column: column)
                        let cell = game.cells[index]
                        GridButton(cell: cell,
                                   lineWidth: lineWidth,
                                   resetPublisher: resetPublisher,
                                   onClick: { onClick(at: index) })
                        // Only enable empty buttons, and only during the game.
                        .disabled(!cell.isEmpty || !game.isOngoing)
                        // Shapes expand to take up as much space as possible.
                        // Without padding, the buttons meet at the center of
                        // the grid lines, so we add padding equal to half the
                        // line width to keep them within their bounds.
                        .padding(lineWidth / 2)
                    }
                }
            }
        }
        .background(GridLines(lineWidth: lineWidth,
                              animationPercentage: animationCompletion))
        .frame(width: length, height: length)
        .disabled(isDisabled)
        .onReceive(resetPublisher, perform: onReceiveResetEvent)
        .task {
            // Draw the grid lines with animation when it first appears.
            guard animationCompletion == 0 else { return }
            // `isDisabled` should initially be `true`.
            assert(isDisabled)
            await animateGridLines()
            updateNavigationTitle()
            isDisabled = false
        }
    }
    
    /// Starts the grid lines animation,
    /// returning after it's done.
    private func animateGridLines() async {
        // Slightly delay the animation to account for app-start animation.
        withAnimation(.easeOut(duration: 0.75)) {
            animationCompletion = 1
        }
        // Enable the grid after the animation finishes.
        try? await Task.sleep(nanoseconds: 750_000_000)
    }
    
    /// Updates the navigation title to reflect
    /// the current state of the game.
    private func updateNavigationTitle() {
        guard !game.isOngoing else {
            navigationTitle = "Player \(game.player)"
            return
        }
        // Note: In pve mode, the user plays as x.
        let isPVP = !isPVE
        switch game.winner {
        case let winner? where isPVP:
            navigationTitle = "Player \(winner) won!"
        case .x:
            navigationTitle = "You win!"
        case .o:
            navigationTitle = "You lose!"
        case nil:
            navigationTitle = "Draw!"
        }
    }
    
    /// The action performed by the button
    /// at the given index.
    private func onClick(at index: Int) {
        Task {
            // Disable the grid until the turn is done.
            isDisabled = true
            await play(at: index)
            // Play as the AI if the game hasn't ended.
            if isPVE, let indexAI = game.playAI(difficulty: difficulty) {
                await play(at: indexAI)
            }
            isDisabled = false
        }
    }
    
    /// Plays at the given index, updating the navigation
    /// title after the drawing animation is done.
    private func play(at index: Int) async {
        game.play(at: index)
        if game.isOngoing {
            // If the game ended, show the result immediately.
            try? await Task.sleep(nanoseconds: PlayerView.animationDurationNano)
        }
        updateNavigationTitle()
    }
    
    /// The action performed on receiving a reset event.
    private func onReceiveResetEvent() {
        Task {
            if game.turns != 0 {
                // Wait for the cells to finish their reset animation.
                isDisabled = true
                try? await Task.sleep(nanoseconds: PlayerView.animationDurationNano)
            }
            // In pve, the user always starts playing.
            game = TicTacToe(startingPlayer: isPVE ? .x : game.player)
            updateNavigationTitle()
            isDisabled = false
        }
    }
}
