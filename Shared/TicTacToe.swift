/// A type representing a tic-tac-toe game.
///
/// Contains the logic of the game.
struct TicTacToe {
    enum Player: String, CustomStringConvertible {
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
            rawValue.capitalized
        }
    }
    
    /// The grid stored in row-major order.
    ///
    /// `nil` represents an empty position.
    private(set) var grid: [Player?] = Array(repeating: nil,
                                                count: 9)
    
    /// The current-turn player.
    private(set) var currentPlayer: Player
    
    /// The grid indices matching along the
    /// horizontal, vertical, or diagonal direction.
    private var matchingIndices: Set<Int> = []
    
    /// The number of turns that have passed.
    private var turns: Int = 0
    
    /// Creates a game starting with the given player.
    init(startingPlayer: Player) {
        currentPlayer = startingPlayer
    }
    
    /// True iff the current-turn player has won.
    var hasWinner: Bool {
        // No matches yet.
        !matchingIndices.isEmpty
    }
    
    /// True iff no turns have passed.
    var isFirstTurn: Bool {
        turns == 0
    }
    
    /// True iff this game has not ended yet.
    var hasNotEnded: Bool {
        // Either no player won the game, or
        // the board is not completely filled.
        !hasWinner && turns != 9
    }
    
    /// Returns the index of the given position in the array.
    static func index(row: Int, column: Int) -> Int {
        //    0   1   2
        // 0 [0] [1] [2]
        // 1 [3] [4] [5]
        // 2 [6] [7] [8]
        //
        // The indices of each row follow the pattern
        // (3 * row, 3 * row + 1, 3 * row + 2).
        assert([row, column].allSatisfy {
            (0..<3).contains($0)
        })
        return 3 * row + column
    }
    
    /// Returns true iff the element at
    /// the given index is matching.
    func isMatching(at index: Int) -> Bool {
        matchingIndices.contains(index)
    }
    
    /// Returns true iff no player has played at `index`.
    func isEmpty(at index: Int) -> Bool {
        grid[index] == nil
    }
    
    /// Returns true iff the current-turn player can
    /// play at the given index.
    private func canPlay(at index: Int) -> Bool {
        isEmpty(at: index) && hasNotEnded
    }
    
    /// Plays as the current-turn player at the given position, then,
    /// if the game did not end, switches to the next player.
    mutating func play(at index: Int) {
        assert(canPlay(at: index))
        grid[index] = currentPlayer
        // Match the pairs adjacent to the given index along
        // the horizontal, vertical, and diagonal directions.
        for (i, j, k) in TicTacToe.pairsAdjacent(to: index) {
            guard grid[i] == grid[j] && grid[j] == grid[k] else { continue }
            for matchingIndex in [i, j, k] {
                matchingIndices.insert(matchingIndex)
            }
        }
        turns += 1
        if hasNotEnded {
             currentPlayer = currentPlayer.opponent
        }
    }
    
    /// Returns the three-pairs adjacent to the given index
    /// along the horizontal, vertical, and diagonal directions.
    private static func pairsAdjacent(to index: Int) -> [(Int, Int, Int)] {
        //    0   1   2
        // 0 [0] [1] [2]
        // 1 [3] [4] [5]
        // 2 [6] [7] [8]
        //
        // The indices of each row follow the pattern
        // (3 * row, 3 * row + 1, 3 * row + 2).
        let (row, column) = index.quotientAndRemainder(dividingBy: 3)
        let rowStart = 3 * row
        // Initialize with the row and column pairs.
        var pairs = [(rowStart, rowStart + 1, rowStart + 2),
                     (column, column + 3, column + 6)]
        // For the diagonal (0, 4, 8),
        // the row is equal to the column.
        if row == column {
            pairs.append((0, 4, 8))
        }
        // For the other diagonal (2, 4, 6),
        // the sum of the row and column is 2.
        if row + column == 2 {
            pairs.append((2, 4, 6))
        }
        return pairs
    }
}

// MARK: - AI logic
extension TicTacToe {
    /// Returns a score evaluation to determine
    /// approximately how significant playing at
    /// `index` is to winning the game.
    private func heuristic(index: Int) -> Int {
        assert(canPlay(at: index))
        // Give each adjacent three-pair a score.
        return TicTacToe.pairsAdjacent(to: index).map { i, j, k in
            // Count the number of occurances of each player.
            // We assume the current-turn player will play at
            // the given index, so their counter starts at 1.
            var count = (player: 1, opponent: 0)
            [i, j, k]
                .compactMap { index in
                    grid[index]
                }
                .forEach { player in
                    if player == currentPlayer {
                        count.player += 1
                    } else {
                        count.opponent += 1
                    }
                }
            switch count {
            case (3, 0):
                // Matching pair (win).
                return 100
            case (1, 2):
                // Block the opponent from winning.
                return 10
            case (2, 0):
                // Almost winning pair
                return 1
            default:
                // The remaining possible values are
                // (2, 1), (1, 1), and (1, 0), all of
                // which are given score 0 since they
                // neither account for a win nor a loss.
                return 0
            }
        }
        // Add all the scores.
        .reduce(0, +)
    }
    
    /// The indices of the empty grid positions.
    private var emptyIndices: [Int] {
        grid.indices.filter { isEmpty(at: $0) }
    }
    
    /// Assuming ideal players, returns the following values
    /// according to the result of playing at `index`:
    /// - `1` on winning.
    /// - `-1` on losing.
    /// - `0` on a draw.
    ///
    /// - Parameters:
    ///   - index: The index to play at.
    ///   - maximizer: The maximizing player.
    ///   - score: The score of the each player.
    ///   Defaults to the worst possible score for each.
    private mutating func minimax(index: Int,
                                  maximizer: Player,
                                  score: (maximizer: Int, minimizer: Int) = (Int.min, Int.max)) -> Int {
        play(at: index)
        defer {
            // Make sure to undo the changes made by
            // `play(at:)` when we exit this scope.
            undoPlay(at: index)
        }
        guard hasNotEnded else {
            // case draw
            guard hasWinner else { return 0 }
            if currentPlayer == maximizer {
                // case win
                return 1
            } else {
                // case loss
                return -1
            }
        }
        var score = score
        // Terminate when the maximizer's score is not less
        // than the minimizer's score (alpha-beta pruning).
        for nextIndex in emptyIndices where score.maximizer < score.minimizer {
            // Call minimax again and again until the game ends.
            let nextScore = minimax(index: nextIndex,
                                    maximizer: maximizer,
                                    score: score)
            if currentPlayer == maximizer {
                score.maximizer = max(score.maximizer, nextScore)
            } else {
                score.minimizer = min(score.minimizer, nextScore)
            }
        }
        return currentPlayer == maximizer ? score.maximizer : score.minimizer
    }
    
    /// Undos the action of playing at `index`,
    /// assuming it was the last one played at.
    private mutating func undoPlay(at index: Int) {
        assert(!isEmpty(at: index))
        if hasNotEnded {
            currentPlayer = currentPlayer.opponent
        } else {
            // We need to clear the matching indices
            // only if this game has ended.
            matchingIndices.removeAll()
        }
        turns -= 1
        grid[index] = nil
    }
    
    /// A type describing the difficulty levels of the AI.
    enum Difficulty: String, CaseIterable, Identifiable {
        /// The AI chooses randomly.
        case easy
        
        /// The AI chooses according
        /// to a heuristic function.
        case medium
        
        /// The AI chooses according
        /// to the minimax algorithm.
        case hard
        
        var id: Self { self }
    }
    
    /// Returns the best move (index) to play at
    /// according to the given difficulty.
    ///
    /// If the game has ended, returns `nil`.
    mutating func bestMove(difficulty: Difficulty) -> Int? {
        guard hasNotEnded else { return nil }
        switch difficulty {
        case .easy:
            return emptyIndices.randomElement()
        case .medium:
            return emptyIndices
                // The indices are shuffled to make
                // the choice less deterministic.
                .shuffled()
                .max(by: {
                    heuristic(index: $0)
                })
        case .hard:
            return emptyIndices.max(by: {
                minimax(index: $0,
                        maximizer: currentPlayer)
            })
        }
    }
}

extension Sequence {
    /// Returns the maximum element in this sequence
    /// by the given property.
    ///
    /// If this sequence is empty, returns `nil`.
    ///
    /// - Parameter property: A closure to map
    /// each element to its compared property.
    func max<T : Comparable>(by property: (Element) -> T) -> Element? {
        var iterator = makeIterator()
        // Check if the sequence is empty.
        guard let first = iterator.next() else { return nil }
        // Assume the first element is the max.
        var max = (element: first, property: property(first))
        // Loop over the rest of the elements.
        // If our assumption is incorrect and
        // there exists an element whose property
        // is greater, update the max value.
        while let nextElement = iterator.next() {
            let nextProperty = property(nextElement)
            if nextProperty > max.property {
                max = (nextElement, nextProperty)
            }
        }
        return max.element
    }
}
