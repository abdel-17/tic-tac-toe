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
    @Binding var game: TicTacToe
    
    @Binding var willReset: Bool
    
    let isPVE: Bool
    
    /// The width of the drawing line.
    let lineWidth: Double
    
    /// True iff an animation is occuring.
    @State private var isAnimating = true
    
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
                        button(at: 3 * row + column)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(GridLines(lineWidth: lineWidth,
                              animationCompletion: animationCompletion))
        .onChange(of: willReset) { willReset in
            if willReset {
                Task {
                    await self.reset()
                    self.willReset = false
                }
            }
        }
        .task {
            animationCompletion = 1
            await Task.sleep(seconds: 1)
            isAnimating.toggle()
        }
        .disabled(isAnimating)
    }
        
    /// Returns the button at the given index.
    private func button(at index: Int) -> some View {
        Button {
            Task {
                guard game.hasNotEnded else {
                    await self.reset()
                    return
                }
                await play(at: index)
            }
        } label: {
            Cell(player: game.grid[index],
                 isMatching: game.isMatching(at: index),
                 lineWidth: lineWidth,
                 animationCompletion: cellAnimationCompletions[index])
        }
        .buttonStyle(.borderless)
        .disabled(!game.isEmpty(at: index) && game.hasNotEnded)
    }
    
    /// Sets the current-turn player at `index`,
    /// and returns after the cell's animation completes.
    private func setPlayer(at index: Int) async {
        game.play(at: index)
        withAnimation(Cell.animation) {
            cellAnimationCompletions[index] = 1
        }
        await Task.sleep(seconds: Cell.animationDuration)
    }
    
    /// Plays the game at `index`.
    private func play(at index: Int) async {
        isAnimating.toggle()
        await setPlayer(at: index)
        if isPVE, let move = game.moveHavingBestHeuristic() {
            await setPlayer(at: move)
        }
        isAnimating.toggle()
    }
    
    /// Resets the grid.
    func reset() async {
        // Only reset when needed.
        guard !game.isFirstTurn else { return }
        isAnimating.toggle()
        withAnimation(Cell.animation) {
            cellAnimationCompletions = Array(repeating: 0,
                                             count: 9)
        }
        await Task.sleep(seconds: Cell.animationDuration)
        game = TicTacToe(startingPlayer: .x)
        isAnimating.toggle()
    }
}
