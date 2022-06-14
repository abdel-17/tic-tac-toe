import SwiftUI

extension Array where Element == Double {
    /// An array of 9 doubles initialized with zeros.
    static var allZeros: [Double] {
        Array(repeating: 0.0, count: 9)
    }
}

extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for the given time in seconds.
    static func sleep(seconds: Double) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1e9))
        } catch {
            #if DEBUG
            print("Sleep task interrupted!")
            #endif
        }
    }
}

/// The view model holding the data presented to the user.
///
/// This class is marked with `@MainActor` to update
/// the UI on the main thread.
@MainActor class ViewModel: ObservableObject {
    @Published private(set) var game = TicTacToe(startingPlayer: .x)
    
    /// A Boolean value to switch between player-vs-enemy
    /// and player-vs-player game modes.
    @Published private(set) var isPVE = true
    
    /// The animation completion percentage of the grid.
    @Published private(set) var gridAnimationCompletion = 0.0
    
    /// The animation completion percentage of each cell.
    @Published private(set) var cellAnimationCompletions = Array.allZeros
    
    /// A Boolean value to check if an animation is occuring.
    @Published private(set) var isAnimating = true
    
    /// The message displayed to the user.
    @Published private(set) var displayedMessage = "Your turn!"
    
    /// Updates the displayed message
    private func updateDisplayedMessage() {
        var newMessage: String {
            if game.hasEnded {
                guard let winner = game.winner else { return "Draw!" }
                if isPVE {
                    switch winner {
                    case .x:
                        return "You won!"
                    case .o:
                        return "You lost!"
                    }
                }
                return "Player \(winner) won!"
            }
            // If we are in pve mode, we don't need
            // to check if the current player is x
            // because the text is hidden while the
            // opponent is playing.
            return isPVE ? "Your turn!" : "Player \(game.currentPlayer)"
        }
        displayedMessage = newMessage
    }
    
    /// Starts drawing the grid lines.
    func startGridAnimation() async {
        gridAnimationCompletion = 1
        await Task.sleep(seconds: 1)
        isAnimating = false
    }
    
    /// Sets the current-turn player at `index`,
    /// and returns after the animation is finished.
    private func setPlayer(at index: Int) async {
        game.play(at: index)
        withAnimation(Cell.animation) {
            cellAnimationCompletions[index] = 1
        }
        await Task.sleep(seconds: Cell.animationDuration)
    }
    
    /// Plays the game at `index` with animation.
    func play(at index: Int) async {
        isAnimating = true
        await setPlayer(at: index)
        if isPVE, let move = game.moveWithBestHeuristic() {
            await setPlayer(at: move)
        }
        isAnimating = false
        updateDisplayedMessage()
    }
    
    /// Resets the cells with animation.
    private func resetCells() async {
        // Reset only when needed.
        guard !game.isFirstTurn else { return }
        isAnimating = true
        withAnimation(Cell.animation) {
            cellAnimationCompletions = Array.allZeros
        }
        await Task.sleep(seconds: Cell.animationDuration)
        isAnimating = false
    }
    
    /// Starts a new game.
    ///
    /// In pvp mode, the starting player of the new game
    /// is the current player. In pve, however, the starting
    /// player is always x.
    func startNewGame() async {
        await resetCells()
        game = TicTacToe(startingPlayer: isPVE ? .x : game.currentPlayer)
        updateDisplayedMessage()
    }
    
    /// Switches between pve and pvp mode.
    func switchGameMode() async {
        isPVE.toggle()
        await startNewGame()
    }
}
