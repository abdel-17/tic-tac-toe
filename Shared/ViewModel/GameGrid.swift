import SwiftUI

extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for the given time in seconds.
    static func sleep(seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(1e9 * seconds))
    }
}

extension UserDefaults {
    /// The stored value of `isPVP`
    /// with default value `false`.
    var isPVP: Bool {
        get { bool(forKey: "isPVP") }
        set { set(newValue, forKey: "isPVP") }
    }

    /// The stored value of `difficulty`
    /// with default value `.medium`.
    var difficulty: TicTacToe.Difficulty {
        get {
            guard let rawValue = string(forKey: "rawDifficulty") else { return .medium }
            return .init(rawValue: rawValue)!
        }
        set {
            set(newValue.rawValue, forKey: "rawDifficulty")
        }
    }
}

/// The view model of the tic-tac-toe grid.
@MainActor class GameGrid: ObservableObject {
    /// The tic-tac-toe game model.
    @Published private var game = TicTacToe(startingPlayer: .x)
    
    /// The animation progress of each cell.
    @Published private var cellsAnimationProgress = Array(repeating: 0.0, count: 9)
    
    /// A Boolean value to disable the grid
    /// while a cell is animating.
    ///
    /// This prevents invalid UI state such as
    /// the user playing the AI's turn.
    @Published private(set) var isDisabled = false
    
    /// A Boolean value to toggle between
    /// pvp and pve game modes.
    @Published private(set) var isPVP = UserDefaults.standard.isPVP {
        didSet {
            UserDefaults.standard.isPVP = self.isPVP
        }
    }
    
    /// The difficulty level of the game's AI.
    @Published var difficulty = UserDefaults.standard.difficulty {
        didSet {
            UserDefaults.standard.difficulty = self.difficulty
        }
    }
    
    /// Returns the cell at the given position
    /// along with its animation progress.
    subscript(index: Int) -> (cell: TicTacToe.Cell, animationProgress: Double) {
        (game.cells[index], cellsAnimationProgress[index])
    }
    
    /// True iff the game has ended.
    var gameHasEnded: Bool {
        // No winner and not a draw (none of the cells are empty).
        game.playerHasWon || !game.cells.anySatisfy(\.isEmpty)
    }
    
    /// True iff no turns have passed
    /// since the game started.
    var isFirstTurn: Bool {
        game.cells.allSatisfy(\.isEmpty)
    }
    
    /// A string describing the current game state.
    var title: String {
        if gameHasEnded {
            guard game.playerHasWon else { return "Draw!" }
            switch game.currentPlayer {
            case let winner where isPVP:
                return "Player \(winner) won!"
            case .x:
                // In pve mode, player x is the user.
                return "You won!"
            case .o:
                return "You lost!"
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
    func play(at index: Int) async {
        await disableWhileRunning {
            await setPlayer(at: index)
            if !isPVP, let move = game.bestMove(difficulty: difficulty) {
                await setPlayer(at: move)
            }
        }
    }
    
    /// Resets the grid, then starts a new game,
    /// switching the game mode if the passed
    /// value is `true`.
    func reset(switchingGameMode: Bool = false) async {
        // If the cells are all empty, we don't need
        // to wait for any animation to finish.
        if !isFirstTurn {
            await disableWhileRunning {
                withAnimation(PlayerView.animation) {
                    cellsAnimationProgress = Array(repeating: 0.0, count: 9)
                }
                await Task.sleep(seconds: PlayerView.animationDuration)
            }
        }
        if switchingGameMode { isPVP.toggle() }
        // The user (player x) always starts in pve mode.
        game = TicTacToe(startingPlayer: isPVP ? game.currentPlayer : .x)
    }
}
