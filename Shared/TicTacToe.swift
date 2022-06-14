/// A type representing a tic-tac-toe game.
///
/// Contains the logic of the game.
struct TicTacToe {
    enum Player: CustomStringConvertible {
        case x, o
        
        var opponent: Player {
            switch self {
            case .x:
                return .o
            case .o:
                return .x
            }
        }
        
        var description: String {
            switch self {
            case .x:
                return "X"
            case .o:
                return "O"
            }
        }
    }
    
    /// The grid stored in a row-major order.
    ///
    /// `nil` represents an empty position.
    private(set) var grid: [Player?] = Array(repeating: nil,
                                                count: 9)
    
    /// The current-turn player.
    private(set) var currentPlayer: Player
    
    /// The indices of the elements matching along either
    /// one of the horizontal, vertical, and diagnoal directions.
    private var matchingIndices: Set<Int> = []
    
    /// The number of turns that have passed.
    private var turns: Int = 0
    
    /// Creates a new game starting with the given player.
    init(startingPlayer: Player) {
        currentPlayer = startingPlayer
    }
    
    /// The winner of the game.
    var winner: Player? {
        // No matches yet.
        guard !matchingIndices.isEmpty else { return nil }
        return currentPlayer
    }
    
    /// True iff the current turn is the first.
    var isFirstTurn: Bool {
        // No turns have passed.
        turns == 0
    }
    
    /// True iff this game has ended.
    var hasEnded: Bool {
        // Either the player won the game,
        // or the board is filled entirely.
        !matchingIndices.isEmpty || turns == 9
    }
    
    /// Returns true iff the grid is empty at `index`.
    func isEmpty(at index: Int) -> Bool {
        grid[index] == nil
    }
    
    /// Returns true iff the player at the given index is matching
    /// along either the horizontal, vertical, or diagonal direction.
    func isMatching(at index: Int) -> Bool {
        matchingIndices.contains(index)
    }
    
    /// A three-pair of indices.
    private typealias Pair = (Int, Int, Int)
    
    /// Returns the three-pairs adjacent to the given position
    /// along the horizontal, vertical, and diagonal directions.
    private static func pairsAdjacent(to index: Int) -> [Pair] {
        //    0   1   2
        // 0 [0] [1] [2]
        // 1 [3] [4] [5]
        // 2 [6] [7] [8]
        //
        // The indices of each row are in the form
        // (3 * row, 3 * row + 1, 3 * row + 2).
        // The quotient of division by 3 returns the row,
        // and the remainder returns the column.
        let (row, column) = index.quotientAndRemainder(dividingBy: 3)
        let rowStart = 3 * row
        // Initialize with the row and column pairs.
        // The indices of the column differ by 3,
        // while that of the row differ by 1.
        var pairs: [Pair] = [(rowStart, rowStart + 1, rowStart + 2),
                             (column, column + 3, column + 6)]
        // The first diagonal pair is (0, 4, 8).
        // The row is always equal to the column.
        if row == column {
            pairs.append((0, 4, 8))
        }
        // The second diagonal pair is (2, 4, 6).
        // The sum of the row and column always equals 2.
        if row + column == 2 {
            pairs.append((2, 4, 6))
        }
        return pairs
    }
    
    /// Sets the player at the given index
    /// and tries to find a match.
    mutating func play(at index: Int) {
        // The given position must be empty
        // and the game must still be ongoing.
        precondition(isEmpty(at: index) && !hasEnded)
        grid[index] = currentPlayer
        // Match along all possible directions.
        for (i, j, k) in TicTacToe.pairsAdjacent(to: index) {
            guard grid[i] == grid[j] && grid[j] == grid[k] else {
                // Not matching. Try the next one.
                continue
            }
            for matchingIndex in [i, j, k] {
                matchingIndices.insert(matchingIndex)
            }
        }
        turns += 1
        if !hasEnded {
             // Continue playing.
             currentPlayer = currentPlayer.opponent
        }
    }
}

// MARK: - AI
extension TicTacToe {
    /// Returns a score evaluation to determine
    /// how significant playing at the given index
    /// is to winning the game.
    private func heuristic(move: Int) -> Int {
        assert(isEmpty(at: move))
        // Give each adjacent three-pair a score.
        return TicTacToe.pairsAdjacent(to: move).map { i, j, k in
            // Count the number of occurances of each player.
            // We assume the current-turn player has already
            // played (but not yet set in the board array),
            // so their count starts at 1.
            var count = (player: 1, opponent: 0)
            for index in [i, j, k] {
                switch grid[index] {
                case currentPlayer:
                    count.player += 1
                case currentPlayer.opponent:
                    count.opponent += 1
                default:
                    break
                }
            }
            switch count {
            case (3, 0):
                // Matching pair (win).
                return 1000
            case (1, 2):
                // Block the opponent from winning.
                return 100
            case (2, 0):
                // Almost winning pair
                return 10
            case (1, 0):
                // We give a small score to occupying
                // a single position. This helps the
                // AI make better decisions early on.
                return 1
            default:
                // The only remaining possible values are (2, 1)
                // and (1, 1). Being blocked from winning is given
                // score 0 as it does not evaluate to a win or loss.
                assert((1...2).contains(count.player) && count.opponent == 1)
                return 0
            }
        }
        // Add all the scores.
        .reduce(0, +)
    }
    
    /// Returns the move (index) having the best heuristic.
    ///
    /// If the game ended, `nil` is returned.
    func moveWithBestHeuristic() -> Int? {
        grid.indices
            // Filter out the occupied positions
            .filter { index in
                isEmpty(at: index)
            }
            // The indices are shuffled to make
            // the choice less deterministic.
            .shuffled()
            // Choose the index having max heuristic.
            .max { previous, next in
                heuristic(move: next) > heuristic(move: previous)
            }
    }
}
