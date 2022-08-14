import SwiftUI

/// A button for resetting the grid.
struct RestartButton: View {
    @EnvironmentObject var grid: GameGrid
    
    var body: some View {
        Button {
            Task { await grid.reset() }
        } label: {
            Label("Restart", systemImage: "arrow.counterclockwise")
        }
    }
}

/// A button for switching the game mode.
struct SwitchGameModeButton: View {
    @EnvironmentObject var grid: GameGrid
    
    var body: some View {
        Button {
            Task { await grid.reset(switchingGameMode: true) }
        } label: {
            Label(grid.isPVP ? "2 Players" : "1 Player",
                  systemImage: grid.isPVP ? "person.2" : "person")
        }
    }
}

/// A picker for the difficulty level.
struct DifficultyPicker: View {
    @EnvironmentObject var grid: GameGrid
    
    var body: some View {
        Picker(selection: $grid.difficulty) {
            ForEach(TicTacToe.Difficulty.allCases) { difficulty in
                Text(difficulty.rawValue.capitalized)
                    .tag(difficulty)
            }
        } label: {
            Label("CPU Difficulty", systemImage: "speedometer")
        }
        .pickerStyle(.menu)
    }
}

/// A picker for the app's appearance.
struct AppearancePicker: View {
    @Binding var selection: Appearance
    
    var body: some View {
        Picker(selection: $selection) {
            ForEach(Appearance.allCases) { appearance in
                Text(appearance.rawValue.capitalized)
                    .id(appearance)
            }
        } label: {
            Label("Appearance", systemImage: "sun.max")
        }
        .pickerStyle(.menu)
    }
}
