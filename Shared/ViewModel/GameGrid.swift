import SwiftUI

extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for the given time in seconds.
    static func sleep(seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(1e9 * seconds))
    }
}

/// The view model of the tic-tac-toe grid.
@MainActor class GameGrid: ObservableObject {
    /// The tic-tac-toe game model.
    @Published private(set) var game = TicTacToe(startingPlayer: .x)
    
    /// The animation progress of each cell.
    @Published private(set) var cellsAnimationProgress = Array(repeating: 0.0, count: 9)
    
    /// A Boolean value to disable the grid
    /// to avoid invalid UI state.
    @Published private(set) var isDisabled = false
    
    /// A Boolean value to toggle between
    /// pvp and pve game modes.
    @Published private(set) var isPVP = UserDefaults.standard.bool(forKey: "isPVP") {
        didSet {
            UserDefaults.standard.set(isPVP, forKey: "isPVP")
        }
    }
    
    /// A string describing the current game state.
    var title: String {
        guard game.hasNotEnded else {
            switch game.winner {
            case let winner? where isPVP:
                return "Player \(winner) won!"
            case .x:
                // In pve mode, player x is the user.
                return "You won!"
            case .o:
                return "You lost!"
            case nil:
                return "Draw!"
            }
        }
        return "Player \(game.currentPlayer)"
    }
    
    /// Runs the given asynchronous closure,
    /// disabling this grid until it returns.
    private func disableWhileRunning(_ body: () async -> Void) async {
        isDisabled = true
        await body()
        isDisabled = false
    }
    
    /// Sets the current player at the given index and
    /// awaits for cell's animation to finish.
    private func setPlayer(at index: Int) async {
        game.play(at: index)
        withAnimation(PlayerView.animation) {
            cellsAnimationProgress[index] = 1.0
        }
        await Task.sleep(seconds: PlayerView.animationDuration)
    }
    
    /// Plays the game as the current player at `index`,
    /// then, if the game mode is pve, plays as the AI.
    func play(at index: Int, difficulty: TicTacToe.Difficulty) async {
        guard !isPVP else {
            await setPlayer(at: index)
            return
        }
        // Disable the grid to prevent the user from
        // playing during the AI's turn.
        await disableWhileRunning {
            await setPlayer(at: index)
            if let move = game.bestMove(difficulty: difficulty) {
                await setPlayer(at: move)
            }
        }
    }
    
    /// Resets the grid, then starts a new game,
    /// switching the game mode if the passed
    /// value is `true`.
    func reset(switchingGameMode: Bool = false) async {
        // Prevent the user from playing while the grid
        // is being disabled.
        await disableWhileRunning {
            // If the cells are all empty, we don't need
            // to wait for any animation to finish.
            if !game.cells.allSatisfy(\.isEmpty) {
                withAnimation(PlayerView.animation) {
                    cellsAnimationProgress = Array(repeating: 0.0, count: 9)
                }
                await Task.sleep(seconds: PlayerView.animationDuration)
            }
            if switchingGameMode { isPVP.toggle() }
            // The user (player x) always starts in pve mode.
            game = TicTacToe(startingPlayer: isPVP ? game.currentPlayer : .x)
        }
    }
}
