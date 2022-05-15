import SwiftUI

struct ContentView : View {
    @State private var game = TicTacToe()
    
    /// The number of wins of each player.
    @State private var score = (x: 0, o: 0)
    
    /// True iff no player has played yet.
    @State private var isFirstTurn = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text("X")
                            .foregroundColor(.teal)
                        
                        Text(String(score.x))
                    }
                    Spacer()
                    
                    Text(displayedMessage)
                    
                    Spacer()
                    VStack {
                        Text("O")
                            .foregroundColor(.yellow)
                        
                        Text(String(score.o))
                    }
                    Spacer()
                }
                
                GeometryReader { bounds in
                    grid3x3(size: 0.85 * min(bounds.size.width, bounds.size.height))
                        .frame(width: bounds.size.width,
                               height: bounds.size.height)
                }
                
                Button(isFirstTurn ? "RESET" : "NEW GAME") {
                    withAnimation {
                        if isFirstTurn {
                            score = (0, 0)
                        } else {
                            game.reset()
                            isFirstTurn = true
                        }
                    }
                }
                .foregroundColor(.red)
                .buttonStyle(PlainButtonStyle())
            }
            .font(.title.bold())
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 300, minHeight: 400)
        }
    }
    
    /// The message displayed to the player.
    private var displayedMessage: String {
        game.hasEnded ?
        game.playerHasWon ? "You win!" : "Draw" :
        "Player \(game.player.description)"
    }
    
    /// Returns a centered, evenly-spaced 3x3 grid of buttons.
    private func grid3x3(size: CGFloat) -> some View {
        ZStack {
            Color.white
                .frame(width: size, height: size)
            
            VStack(spacing: 0.025 * size) {
                ForEach(0..<3) { row in
                    HStack(spacing: 0.025 * size) {
                        ForEach(0..<3) { column in
                            button(row, column, size: 0.95 * size / 3)
                        }
                    }
                }
            }
        }
    }
    
    /// Returns a button having the given size,
    /// positioned at the given row and column.
    private func button(_ row: Int, _ column: Int, size: CGFloat) -> some View {
        Button {
            withAnimation {
                game.playAt(row, column)
                isFirstTurn = false
                if game.playerHasWon {
                    switch game.player {
                    case .x:
                        score.x += 1
                    case .o:
                        score.o += 1
                    }
                }
            }
        } label: {
            Text(game[row, column]?.description ?? "")
                .frame(width: size, height: size)
        }
        .font(.system(size: size / 2))
        .foregroundColor(game.isMatchingAt(row, column) ? .green :
                         game[row, column] == .x ? .teal : .yellow)
        .background(.black)
        .buttonStyle(BorderlessButtonStyle())
        .disabled(game.hasEnded || game[row, column] != nil)
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
