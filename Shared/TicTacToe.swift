struct TicTacToe {
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
    
    struct Cell {
        /// The player at this cell, if any.
        fileprivate(set) var player: Player?
        
        /// True if this cell is one of the
        /// matching triplets in the grid.
        fileprivate(set) var isMatching: Bool
        
        /// Creates a cell with the given properties.
        private init(player: Player?, isMatching: Bool) {
            self.player = player
            self.isMatching = isMatching
        }
        
        /// An empty cell, with `player` and
        /// `isMatching` set to `nil` and
        /// `false`, respectively.
        static var empty: Cell {
            Cell(player: nil, isMatching: false)
        }
        
        /// True if the player at this cell is `nil`.
        var isEmpty: Bool {
            player == nil
        }
    }
    
    /// The grid cells in row-major order.
    private(set) var cells = Array(repeating: Cell.empty, count: 9)
    
    /// The player of the current turn.
    private(set) var player: Player
    
    /// The winner of this game, if any.
    private(set) var winner: Player? = nil
    
    /// The number of turns that have passed.
    private(set) var turns = 0
    
    /// Creates a tic-tac-toe game,
    /// starting with the given player.
    init(startingPlayer: Player) {
        player = startingPlayer
    }
    
    /// True if this game hasn't ended yet.
    var isOngoing: Bool {
        // Neither player won and it isn't a draw.
        winner == nil && turns != 9
    }
    
    /// Returns the row-major index of the
    /// given position in the grid.
    func index(row: Int, column: Int) -> Int {
        //    0   1   2
        // 0 [0] [1] [2]
        // 1 [3] [4] [5]
        // 2 [6] [7] [8]
        //
        // Row offset is 1 and column offset is 3.
        // grid[row, column] = grid[3 * row + column]
        let range = 0..<3
        precondition(range.contains(row) && range.contains(column))
        return 3 * row + column
    }
}

// - MARK: PVP game logic
extension TicTacToe {
    /// Returns the row-major index triplets
    /// in the grid containing the given index.
    private func indexTriplets(containing index: Int) -> [[Int]] {
        // index = 3 * row + column
        // Notice that the row and column are the quotient and
        // remainder, respectively, of dividing `index` by 3.
        let (row, column) = index.quotientAndRemainder(dividingBy: 3)
        // Initialize with the row and column triplets.
        let rowStartIndex = 3 * row
        var triplets = [
            [rowStartIndex, rowStartIndex + 1, rowStartIndex + 2],
            [column, column + 3, column + 6]
        ]
        // Add the diagonal triplets if `index` belongs to them.
        if row == column {
            triplets.append([0, 4, 8])
        }
        if row + column == 2 {
            triplets.append([2, 4, 6])
        }
        return triplets
    }
    
    /// Returns true if the players at
    /// the given indices are equal.
    private func isMatching(triplet: [Int]) -> Bool {
        // We should only match triplets.
        assert(triplet.count == 3)
        return triplet.allEqual { index in cells[index].player }
    }
    
    /// Plays at the given index, then switches
    /// control to the next player.
    mutating func play(at index: Int) {
        precondition(winner == nil && cells[index].isEmpty)
        cells[index].player = player
        // Check for matching triplets. We only need to check
        // the ones including `index` since we know the rest
        // are not matching (winner is nil, after all).
        for triplet in indexTriplets(containing: index) where isMatching(triplet: triplet) {
            winner = player
            for index in triplet {
                cells[index].isMatching = true
            }
        }
        player.switchToOpponent()
        turns += 1
    }
}

// MARK: - PVE game logic
extension TicTacToe {
    /// Returns a score that approximates the
    /// best position to play at.
    ///
    /// This score is just an approximation.
    /// It doesn't guarantee a perfect result.
    private func heuristic(_ index: Int) -> Int {
        assert(cells[index].isEmpty)
        // Give each triplet a score according to the number of
        // occurances of each player, adding them all up.
        var score = 0
        for triplet in indexTriplets(containing: index) {
            switch playerCounts(at: triplet) {
            case (2, 0):
                // Playing at this position results in a win,
                // so we return the best possibly score.
                return Int.max
            case (0, 2):
                // Next up in priority is blocking the opponent.
                score += 10
            case (1, 0):
                // After playing at this position, `count` becomes (2, 0),
                // forcing the opponent to block. Blocking the opponent
                // has higher priority because what's the point of forcing
                // them to block if they can win on the next turn anyway?
                score += 1
            default:
                // The remaining possible values are:
                // - (2, 1)
                // - (1, 1)
                // - (1, 0)
                // They neither account for a win nor a loss,
                // so they don't affect the score.
                break
            }
        }
        return score
    }
    
    /// Returns the count of each player
    /// in the grid at the given indices.
    private func playerCounts(at indices: [Int]) -> (player: Int, opponent: Int) {
        indices.reduce(into: (player: 0, opponent: 0)) { count, index in
            // Skip empty cells.
            guard let player = cells[index].player else { return }
            // Increment the count of the player.
            if (player == self.player) {
                count.player += 1
            } else {
                count.opponent += 1
            }
        }
    }
    
    /// Returns `1` if playing at the given index results in
    /// the maximizer's win, `-1` if it results in their loss,
    /// and `0` if it results in a draw.
    ///
    /// - Parameters:
    ///   - index: The index to play at.
    ///   - isMax: Pass `true` if the current player is the maximizer
    ///   - score: The best score obtained so far for each player.
    private mutating func minimax(index: Int, isMax: Bool, score: (max: Int, min: Int)) -> Int {
        assert(cells[index].isEmpty)
        cells[index].player = player
        turns += 1
        defer {
            // Undo the changes after returning.
            cells[index].player = nil
            turns -= 1
        }
        // Check if either player won.
        if indexTriplets(containing: index).anySatisfy(isMatching) {
            return isMax ? 1 : -1
        }
        // Check if this game ended in a draw.
        guard turns != 9 else { return 0 }
        // Switch control to the opponent and recursively call
        // `minimax` until we reach one of the above conditions.
        player.switchToOpponent()
        let isMax = !isMax
        defer {
            // Again, we must remember to undo the changes after returning.
            player.switchToOpponent()
        }
        var score = score
        for childIndex in cells.indices where cells[childIndex].isEmpty {
            // Alpha-beta pruning.
            guard score.max < score.min else { break }
            // Update the score if the child's is better. The maximizer seeks to
            // maximizer the score. Conversly, the minimizer seeks to minimze it.
            let childScore = minimax(index: childIndex, isMax: isMax, score: score)
            if isMax {
                score.max = max(score.max, childScore)
            } else {
                score.min = min(score.min, childScore)
            }
        }
        return isMax ? score.max : score.min
    }
    
    /// The AI difficulty levels.
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
    
    /// Returns the index chosen by the AI
    /// to play at, given its difficulty level.
    ///
    /// If the game has ended, returns `nil`.
    mutating func playAI(difficulty: Difficulty) -> Int? {
        // Check if the game has ended.
        guard isOngoing else { return nil }
        // Filter out the occupied cells.
        let emptyIndices = cells.indices.filter { index in cells[index].isEmpty }
        switch difficulty {
        case .easy:
            return emptyIndices.randomElement()
        case .medium:
            // Shuffling the indices makes the AI more random
            // when there are many positions with the same score.
            // This happens mostly at the start of the game where
            // most cells are empty. It's more natural than having
            // it pick the first empty cell every time.
            return emptyIndices.shuffled().max(by: heuristic)
        case .hard:
            return emptyIndices.max { index in
                // Start with the worst possible score for each player.
                minimax(index: index, isMax: true, score: (max: Int.min, min: Int.max))
            }
        }
    }
}


