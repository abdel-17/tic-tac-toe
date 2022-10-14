import SwiftUI

/// A button for resetting the grid.
struct RestartButton : View {
    var resetPublisher: EventPublisher
    
    var body: some View {
        Button {
            resetPublisher.send()
        } label: {
            Label("Restart", systemImage: "arrow.counterclockwise")
        }
    }
}

/// A button for switching the game mode.
struct SwitchGameModeButton : View {
    @AppStorage("isPVE") private var isPVE = true
    
    var resetPublisher: EventPublisher
    
    var body: some View {
        Button {
            isPVE.toggle()
            resetPublisher.send()
        } label: {
            Label(isPVE ? "1 Player" : "2 Players",
                  systemImage: isPVE ? "person" : "person.2")
        }
    }
}

/// A picker for the difficulty level.
struct DifficultyPicker : View {
    @AppStorage("difficulty") var difficulty = TicTacToe.Difficulty.medium
    
    var body: some View {
        Picker(selection: $difficulty) {
            ForEach(TicTacToe.Difficulty.allCases) { difficulty in
                Text(difficulty.rawValue.capitalized)
                    .tag(difficulty)
            }
        } label: {
            Label("CPU Difficulty", systemImage: "speedometer")
        }
    }
}

/// A picker for the app's appearance.
struct AppearancePicker : View {
    @AppStorage("appearance") var appearance = Appearance.system
    
    var body: some View {
        Picker(selection: $appearance) {
            ForEach(Appearance.allCases) { appearance in
                Text(appearance.rawValue.capitalized)
                    .id(appearance)
            }
        } label: {
            Label("Appearance", systemImage: "sun.max")
        }
    }
}
