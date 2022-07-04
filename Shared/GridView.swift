import SwiftUI

extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for the given time in seconds.
    static func sleep(seconds: Double) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1e9))
        } catch {
            #if DEBUG
            print("Task interrupted unexpectedly")
            #endif
        }
    }
}

/// A 3x3 grid of evenly-spaced cells.
struct GridView: View {
    @Binding var state: ContentView.ViewState
    
    /// The width of the drawing line.
    let lineWidth: Double
    
    /// The completion percentage of the
    /// grid lines animation.
    @State private var animationCompletion = 0.0
    
    /// The completion percentage of each
    /// cell's drawing animation.
    @State private var cellAnimationCompletions = Array(repeating: 0.0,
                                                        count: 9)
    
    var body: some View {
        VStack(spacing: lineWidth) {
            ForEach(0..<3) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3) { column in
                        button(at: TicTacToe.index(row: row, column: column))
                    }
                }
            }
        }
        .background(GridLines(lineWidth: lineWidth,
                              animationCompletion: animationCompletion))
        .aspectRatio(contentMode: .fit)
        .disabled(state.disableGrid)
        .onChange(of: state.willReset) { willReset in
            if willReset {
                Task {
                    await self.reset()
                    state.willReset = false
                }
            }
        }
        .task {
            animationCompletion = 1
            // Wait for the grid line animation to finish,
            // then re-enable the grid.
            await Task.sleep(seconds: 1)
            state.disableGrid = false
        }
        
    }
    
    /// Returns the button positioned at the given index.
    private func button(at index: Int) -> some View {
        Button {
            Task {
                guard state.game.hasNotEnded else {
                    await self.reset()
                    return
                }
                await play(at: index)
            }
        } label: {
            Cell(player: state.game.grid[index],
                 lineWidth: lineWidth,
                 isMatching: state.game.isMatching(at: index),
                 animationCompletion: cellAnimationCompletions[index])
        }
        .buttonStyle(.borderless)
        .disabled(!state.game.isEmpty(at: index) && state.game.hasNotEnded)
    }
    
    /// Sets the current-turn player at `index` and
    /// returns after the cell's animation completes.
    private func setPlayer(at index: Int) async {
        state.game.play(at: index)
        withAnimation(Cell.animation) {
            cellAnimationCompletions[index] = 1
        }
        await Task.sleep(seconds: Cell.animationDuration)
    }
    
    /// Plays the game at `index`.
    private func play(at index: Int) async {
        state.disableGrid = true
        await setPlayer(at: index)
        state.disableGrid = false
        if state.isPVE,
           let move = state.game.bestMove(difficulty: state.difficulty) {
            await setPlayer(at: move)
        }
    }
    
    /// Resets the grid.
    func reset() async {
        // Only reset when needed.
        guard !state.game.isFirstTurn else { return }
        state.disableGrid = true
        withAnimation(Cell.animation) {
            cellAnimationCompletions = Array(repeating: 0,
                                             count: 9)
        }
        await Task.sleep(seconds: Cell.animationDuration)
        state.game = TicTacToe(startingPlayer: .x)
        state.disableGrid = false
    }
}
