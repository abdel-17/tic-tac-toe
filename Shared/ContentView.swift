import SwiftUI

struct ContentView: View {
    struct ViewState {
        /// The logic of the game.
       var game = TicTacToe(startingPlayer: .x)
        
        /// A Boolean value to check whether the game
        /// mode is player-vs-enemy or player-vs-player.
        var isPVE = true
        
        /// The method used by the AI to choose its move.
        var difficulty = TicTacToe.Difficulty.medium
        
        /// True iff the grid buttons are disabled.
        var disableGrid = true
        
        /// True iff the grid will reset.
        var willReset = false
    }
    
    @State private var state = ViewState()
    
    var body: some View {
        VStack {
            Text(displayedMessage)
                .font(.title2)
                .bold()
            
            GeometryReader { bounds in
                let width = bounds.size.width
                let height = bounds.size.height
                GridView(state: $state,
                         lineWidth: 0.02 * min(width, height))
                .padding(0.1 * min(width, height))
                .frame(width: width,
                       height: height)
            }
            
            HStack {
                styledButton(systemName: state.isPVE ? "person" : "person.2") {
                    state.isPVE.toggle()
                    state.willReset = true
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                // Difficulty picker
                Picker("Difficulty", selection: $state.difficulty) {
                    ForEach(TicTacToe.Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue.capitalized)
                            .tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 200)
                .opacity(state.isPVE ? 1 : 0)
                .animation(.default, value: state.isPVE)
                
                Spacer()
                
                // Reset button
                styledButton(systemName: "arrow.counterclockwise") {
                    state.willReset = true
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        #if os(macOS)
        .frame(minWidth: 350,
               minHeight: 400)
        #endif
    }
    
    /// The up-to-date displayed message.
    private var displayedMessage: String {
        if state.game.hasNotEnded {
            // Indicate to the user that to wait
            // until the grid is re-renabled.
            guard !state.disableGrid else { return "..." }
            // If we are in pve mode, we don't need to check
            // if the current player is x because the text
            // is hidden while the opponent is playing.
            return state.isPVE ? "Your turn!" : "Player \(state.game.currentPlayer)"
        }
        // The game has ended. Check for draws first.
        guard state.game.hasWinner else { return "Draw!" }
        if state.isPVE {
            // The AI is always player o.
            switch state.game.currentPlayer {
            case .x:
                return "You won!"
            case .o:
                return "You lost!"
            }
        }
        return "Player \(state.game.currentPlayer) won!"
    }
    
    /// Returns a bordeless button whose label is a
    /// circular filled image with a large scale.
    ///
    /// - Parameters:
    ///   - systemName: The system name of the image.
    ///   - action: The action performed by the button.
    private func styledButton(systemName: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .symbolVariant(.fill.circle)
                .symbolRenderingMode(.multicolor)
                .font(.title)
        }
        .buttonStyle(.borderless)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
            
    }
}

