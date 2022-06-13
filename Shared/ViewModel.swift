import SwiftUI

/// The view model holding the data presented to the user.
///
/// This class is marked with `@MainActor` to update
/// the UI on the main thread.
@MainActor class ViewModel: ObservableObject {
    /// A Boolean value to check the game mode (pvp or pve).
    @Published private(set) var isPVE = true
    
    @Published private(set) var game = TicTacToe(startingPlayer: .x)
    
    /// The animation completion percentage of each cell.
    @Published private(set) var animationCompletions = Array(repeating: 0.0,
                                                             count: 9)
    
    /// A Boolean value to keep track of animating cells.
    @Published private(set) var isAnimating = false
    
    /// The message displayed to the user.
    var displayedMessage: String {
        guard !isAnimating else { return "..." }
        if game.hasEnded {
            guard let winner = game.winner else { return "Draw!" }
            if isPVE {
                switch winner {
                case .x:
                    return "You win!"
                case .o:
                    return "You lose!"
                }
            }
            return "Player \(winner) won!"
        }
        // If we are in pve mode, we don't need
        // to check if the current player is x
        // because `isAnimating` is always true
        // while the opponent is playing.
        return isPVE ? "Your turn!" : "Player \(game.currentPlayer)"
    }
    
    /// Sets `isAnimating` to `true`, then after
    /// the animation is done, sets it back to `false`.
    private func toggleIsAnimating() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Cell.animationDuration) { [weak self] in
            self?.isAnimating = false
        }
    }
    
    /// Sets the current-turn player at `index`.
    private func setPlayer(at index: Int) {
        game.play(at: index)
        withAnimation(Cell.animation) {
            animationCompletions[index] = 1
        }
        // If the game ended, do not toggle `isAnimating`
        // to show the message immediately.
        guard !game.hasEnded else { return }
        toggleIsAnimating()
    }
    
    /// Plays the game at `index`.
    func play(at index: Int) {
        setPlayer(at: index)
        if isPVE {
            guard let move = game.bestMove() else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + Cell.animationDuration) { [weak self] in
                self?.setPlayer(at: move)
            }
        }
    }
    
    /// Starts a new game.
    ///
    /// In pvp mode, the starting player of the new game
    /// is the current player. In pve, however, the starting
    /// player is always x.
    func startNewGame() {
        let startingPlayer = isPVE ? .x : game.currentPlayer
        guard !game.isFirstTurn else {
            // No reset animation is needed.
            game = TicTacToe(startingPlayer: startingPlayer)
            return
        }
        withAnimation(Cell.animation) {
            animationCompletions = Array(repeating: 0,
                                         count: 9)
        }
        toggleIsAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + Cell.animationDuration) { [weak self] in
            self?.game = TicTacToe(startingPlayer: startingPlayer)
        }
    }
    
    /// Switches between pve and pvp mode.
    func switchGameMode() {
        isPVE.toggle()
        startNewGame()
    }
}
