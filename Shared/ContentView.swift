import SwiftUI

struct ContentView: View {
    @State private var game = TicTacToe(startingPlayer: .x)
    
    /// A Boolean value to check whether the game
    /// mode is player-vs-enemy or player-vs-player.
    @State private var isPVE = true
    
    /// True iff the grid will reset.
    @State private var willReset = false
    
    var body: some View {
        VStack {
            Text(displayedMessage)
                .font(.title2)
                .bold()
            
            Spacer()
            
            GridView(game: $game,
                     willReset: $willReset,
                     isPVE: isPVE,
                     lineWidth: 7.5)
            .padding()
            
            Spacer()
            
            HStack {
                Button {
                    isPVE.toggle()
                    willReset.toggle()
                } label: {
                    Image(systemName: isPVE ? "person" : "person.2")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button {
                    willReset.toggle()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(.plain)
            .symbolVariant(.fill.circle)
            .symbolRenderingMode(.multicolor)
            .font(.title)
        }
        .padding()
    }
    
    /// The up-to-date displayed message.
    private var displayedMessage: String {
        if game.hasNotEnded {
            // If we are in pve mode, we don't need to check
            // if the current player is x because the text
            // is hidden while the opponent is playing.
            return isPVE ? "Your turn!" : "Player \(game.currentPlayer)"
        }
        // Game has ended. Check for draws first.
        guard let winner = game.winner else { return "Draw!" }
        if isPVE {
            // The AI is always player o.
            switch winner {
            case .x:
                return "You won!"
            case .o:
                return "You lost!"
            }
        }
        return "Player \(winner) won!"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

