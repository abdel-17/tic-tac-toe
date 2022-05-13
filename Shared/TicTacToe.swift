struct TicTacToe {
    /// A tic-tac-toe player.
    enum Player : CustomStringConvertible {
        case x, o
        
        var description: String {
            switch self {
            case .x:
                return "X"
            case .o:
                return "O"
            }
        }
    }
    
    /// An array of 9 players, initially set to `nil`.
    ///
    /// `nil` descibes an empty position.
    private var grid: [Player?] = Array(repeating: nil,
                                         count: 9)
    
    /// The indices of the matching elements in the grid.
    private var matchingIndices: Set<Int> = []
    
    /// The numbers of turns that passed.
    private var turns: Int = 0
    
    /// The current-turn player.
    private(set) var player: Player = .x
    
    /// True iff the current player has won.
    var playerHasWon: Bool {
        !matchingIndices.isEmpty
    }
    
    /// True iff this game has ended.
    var hasEnded: Bool {
        playerHasWon || turns == 9
    }
    
    /// Returns the player at the given row and column.
    subscript(row: Int, column: Int) -> Player? {
        grid[3 * row + column]
    }
    
    /// Returns true if the player won by matching
    /// the given row and column.
    func isMatchingAt(_ row: Int, _ column: Int) -> Bool {
        matchingIndices.contains(3 * row + column)
    }
    
    /// Determines the winner by matching the values
    /// at the given indices.
    private mutating func match(_ i: Int, _ j: Int, _ k: Int) {
        if grid[i] == grid[j] && grid[j] == grid[k] {
            for index in [i, j, k] {
                matchingIndices.insert(index)
            }
        }
    }
    
    /// Plays this game at the given row and column.
    mutating func playAt(_ row: Int, _ column: Int) {
        let index = 3 * row + column
        grid[index] = player
        // Try to match along all possible directions.
        //
        //    0   1   2
        // 0 [0] [1] [2]
        // 1 [3] [4] [5]
        // 2 [6] [7] [8]
        //
        // Match along the given row.
        match(3 * row, 3 * row + 1, 3 * row + 2)
        // Match along the given column.
        match(column, column + 3, column + 6)
        // If we are on the diagnonal (0, 4, 8):
        if row == column {
            match(0, 4, 8)
        }
        // If we are on the diagnonal (2, 4, 6):
        if row + column == 2 {
            match(2, 4, 6)
        }
        turns += 1
        if !playerHasWon {
            player = (player == .x) ? .o : .x
        }
    }
    
    /// Starts a new game with the same starting player
    /// as the current one.
    mutating func reset() {
        for index in grid.indices {
            grid[index] = nil
        }
        matchingIndices.removeAll()
        turns = 0
    }
}
