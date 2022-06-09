import SwiftUI

/// The main view of the game.
struct ContentView: View {
    @State private var grid = TicTacToeGrid(startingPlayer: .x)
    
    /// The animation completion percentage of each cell.
    @State private var animationCompletions = Array(repeating: 0.0,
                                                    count: 9)
    
    /// A Boolean value used to disable the grid
    /// during an animation.
    @State private var disableGrid = false
    
    /// A Boolean value used to to switch between
    /// pvp and pve modes.
    @State private var againstAI = false
    
    /// The duration of the cell's animation.
    private let animationDuration = 0.45
    
    /// The width of the drawing line.
    private let lineWidth = 6.0
    
    var body: some View {
        VStack {
            Text(displayedMessage)
                .font(.title)
                .bold()
            
            Spacer()
            
            gridView
                .padding()
            
            Spacer()
            
            HStack {
                switchGameModeButton
                
                Spacer()
                
                restartButton
            }
            .font(.title)
        }
        .padding()
        .background()
        #if os(macOS)
        .frame(minWidth: 350, minHeight: 400)
        #endif
    }
    
    /// The message displayed to the user.
    private var displayedMessage: String {
        guard !disableGrid else { return "..." }
        if grid.gameHasEnded {
            switch grid.winner {
            case .x:
                return againstAI ? "You won!" : "Player X won!"
            case .o:
                return againstAI ? "You lost!" : "Player O won!"
            case nil:
                return "Draw!"
            }
        }
        switch grid.currentPlayer {
        case .x:
            return againstAI ? "Your turn" : "Player X"
        case .o:
            return "Player O"
        }
    }
    
    /// An evenly-spaced 3x3 grid of cells.
    private var gridView: some View {
        VStack(spacing: lineWidth) {
            ForEach(0..<3) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3) { column in
                        cell(at: 3 * row + column)
                    }
                }
            }
        }
        .background(.primary)
        .disabled(disableGrid)
    }
    
    /// A button that starts a new game.
    private var restartButton: some View {
        Button(action: resetGrid) {
            Image(systemName: "arrow.counterclockwise")
                .symbolVariant(.fill.circle)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
    
    /// A button that switches between pvp and pve modes.
    private var switchGameModeButton: some View {
        Button {
            againstAI.toggle()
            guard !grid.isFirstTurn else {
                grid = TicTacToeGrid(startingPlayer: .x)
                return
            }
            resetGrid()
        } label: {
            Image(systemName: againstAI ? "person" : "person.2")
                .symbolVariant(.fill.circle)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
    }
    
    /// Returns the cell positoned at `index`
    /// according to row-major order.
    private func cell(at index: Int) -> some View {
        Cell(player: grid.players[index],
             lineWidth: lineWidth,
             animationCompletion: animationCompletions[index])
        .foregroundColor(cellForegroundColor(at: index))
        .background()
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            guard !grid.gameHasEnded else {
                resetGrid()
                return
            }
            play(at: index)
        }
        .animation(.easeInOut(duration: animationDuration),
                   value: animationCompletions[index])
        .animation(.easeInOut(duration: animationDuration),
                   value: grid.isMatching(at: index))
        .disabled(!grid.gameHasEnded && !grid.isEmpty(at: index))
    }
    
    /// Returns the foreground color of the cell at `index`.
    private func cellForegroundColor(at index: Int) -> Color? {
        if grid.isMatching(at: index) {
            return .green
        }
        switch grid.players[index] {
        case .x:
            return .red
        case .o:
            return .blue
        case nil:
            return nil
        }
    }
    
    /// Plays at the given index.
    private func play(at index: Int) {
        grid.play(at: index)
        animationCompletions[index] = 1
        if againstAI {
            guard let move = grid.bestMove() else { return }
            disableGrid.toggle()
            // Make the AI play slightly after the
            // player's animation is done.
            delay(by: animationDuration + 0.15) {
                grid.play(at: move)
                animationCompletions[move] = 1
                disableGrid.toggle()
            }
        }
    }
    
    /// Resets the grid.
    private func resetGrid() {
        guard !grid.isFirstTurn else { return }
        animationCompletions = Array(repeating: 0,
                                     count: 9)
        disableGrid.toggle()
        delay(by: animationDuration + 0.15) {
            grid = TicTacToeGrid(startingPlayer: againstAI ? .x : grid.currentPlayer)
            disableGrid.toggle()
        }
    }
    
    /// Delays the exection of the given closure by `duration` seconds.
    private func delay(by duration: Double, _ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration,
                                      execute: action)
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

