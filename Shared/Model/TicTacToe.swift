/// A tic-tac-toe game.
struct TicTacToe {
    /// A tic-tac-toe player.
    enum Player: String, CustomStringConvertible {
        case x, o
        
        /// Replaces this player with their opponent.
        mutating func switchToOpponent() {
            switch self {
            case .x:
                self = .o
            case .o:
                self = .x
            }
        }
        
        var description: String {
            rawValue.uppercased()
        }
    }
    
    /// A tic-tac-toe grid cell.
    struct Cell {
        /// The player at this cell.
        var player: Player? = nil
        
        /// True iff this cell is matching.
        var isMatching = false
        
        /// True iff this cell is empty.
        var isEmpty: Bool {
            player == nil
        }
    }
    
    /// The cells in row-major order.
    private(set) var cells = Array(repeating: Cell(), count: 9)
    
    /// The player of the current turn.
    private(set) var currentPlayer: Player
    
    /// True iff the current player has won.
    private(set) var playerHasWon = false
    
    /// Creates a tic-tac-toe game,
    /// starting with the given player.
    init(startingPlayer: Player) {
        currentPlayer = startingPlayer
    }
}

extension TicTacToe {
    /// True iff this game has not ended yet.
    var hasNotEnded: Bool {
        // Neither player has won and it is not a draw.
        !playerHasWon && cells.anySatisfy(\.isEmpty)
    }
    
    /// Returns the row-major indices of the triplets
    /// adjacent to the given position.
    private func tripletsAdjacent(to index: Int) -> [[Int]] {
        //    0   1   2
        // 0 [0] [1] [2]
        // 1 [3] [4] [5]
        // 2 [6] [7] [8]
        // Row elements are offset by 1 and
        // column elements are offset by 3.
        //
        // grid[row, column] = grid[3 * row + column]
        let (row, column) = index.quotientAndRemainder(dividingBy: 3)
        let rowStart = 3 * row
        // Initialize with the row and column indices.
        var triplets = [
            [rowStart, rowStart + 1, rowStart + 2],
            [column, column + 3, column + 6]
        ]
        // Add the diagonal indices if `index` belongs to them.
        if row == column {
            triplets.append([0, 4, 8])
        }
        if row + column == 2 {
            triplets.append([2, 4, 6])
        }
        return triplets
    }
    
    /// Returns true iff the players at  the given indices are equal.
    private func isMatching(triplet: [Int]) -> Bool {
        assert(triplet.count == 3)
        return triplet.allEqual(by: { cells[$0].player })
    }
    
    /// Returns true iff neither player has won and
    /// the grid is empty at the given index.
    private func canPlay(at index: Int) -> Bool {
        !playerHasWon && cells[index].isEmpty
    }
    
    /// Plays at the given index, then, if neither
    /// player won, switches to the next player.
    mutating func play(at index: Int) {
        assert(canPlay(at: index))
        cells[index].player = currentPlayer
        // Check for matches adjacent to the given index.
        for triplet in tripletsAdjacent(to: index) where isMatching(triplet: triplet) {
            // Found a match.
            playerHasWon = true
            for index in triplet {
                cells[index].isMatching = true
            }
        }
        if hasNotEnded {
            currentPlayer.switchToOpponent()
        }
    }
}

// MARK: - AI logic
extension TicTacToe {
    /// Returns a score that approximates how significant
    /// playing at the given index is to winning.
    private func heuristic(index: Int) -> Int {
        assert(canPlay(at: index))
        // Assign each adjacent triplet a score according
        // to the number of occurances of each player,
        // and add them all up.
        return tripletsAdjacent(to: index).reduce(into: 0) { score, triplet in
            // We assume the current player will play at
            // the given index, so their count starts at 1.
            var count = (player: 1, opponent: 0)
            for index in triplet {
                // Skip empty cells.
                guard let player = cells[index].player else { continue }
                if player == currentPlayer {
                    count.player += 1
                } else {
                    count.opponent += 1
                }
            }
            switch count {
            case (3, 0):
                // Matching triplet (win).
                score += 100
            case (1, 2):
                // Block the opponent from winning.
                score += 10
            case (2, 0):
                // Almost winning triplet
                score += 1
            default:
                // The remaining possible values are
                // (2, 1), (1, 1), and (1, 0), all of
                // which are given score 0 since they
                // neither account for a win nor a loss.
                break
            }
        }
    }
    
    /// The row-major indices of the empty cells.
    private var emptyIndices: [Int] {
        cells.indices.filter { cells[$0].isEmpty }
    }
    
    /// Returns the following values, depending on the
    /// ideal result of playing at the given index:
    /// - `1` if the maximizing player wins.
    /// - `-1` if the minimizing player wins.
    /// - `0` if the game ends in a draw.
    private mutating func minimax(index: Int,
                                  isMax: Bool,
                                  score: (max: Int, min: Int)) -> Int {
        assert(cells[index].isEmpty)
        cells[index].player = currentPlayer
        defer {
            // Clear the current position after we return.
            cells[index].player = nil
        }
        // Check if either player won.
        if tripletsAdjacent(to: index).anySatisfy(isMatching) {
            return isMax ? 1 : -1
        }
        let emptyIndices = emptyIndices
        // Check if this game ended in a draw,
        // aka there are no empty cells.
        guard !emptyIndices.isEmpty else { return 0 }
        // Switch control to the opponent.
        currentPlayer.switchToOpponent()
        let isMax = !isMax
        defer {
            // Switch control back to the current player
            // after we return.
            currentPlayer.switchToOpponent()
        }
        // Loop over the children and update the score.
        // Terminate when the minimizer's score is not greater
        // than the maximizers's (alpha-beta pruning).
        var score = score
        for nextIndex in emptyIndices where score.max < score.min {
            // Keep calling minimax until the game ends.
            let nextScore = minimax(index: nextIndex, isMax: isMax, score: score)
            if isMax {
                score.max = max(score.max, nextScore)
            } else {
                score.min = min(score.min, nextScore)
            }
        }
        return isMax ? score.max : score.min
    }
    
    /// A type describing the difficulty levels of the AI.
    enum Difficulty: String, CaseIterable, Identifiable {
        /// The AI chooses randomly.
        case easy
        
        /// The AI uses a heuristic function to
        /// approximate the best result.
        case medium
        
        /// The AI uses the minimax algorithm.
        case hard
        
        var id: Self { self }
    }
    
    /// Returns the best move (index) to play at
    /// according to the given difficulty.
    ///
    /// If the game has ended, returns `nil`.
    mutating func bestMove(difficulty: Difficulty) -> Int? {
        guard !playerHasWon else { return nil }
        switch difficulty {
        case .easy:
            return emptyIndices.randomElement()
        case .medium:
            return emptyIndices
                // The indices are shuffled to make
                // the choice more random.
                .shuffled()
                .max(by: heuristic)
        case .hard:
            return emptyIndices.max { index in
                // Call minimax with the worst possible score for each player.
                minimax(index: index, isMax: true, score: (max: Int.min, min: Int.max))
            }
        }
    }
}


