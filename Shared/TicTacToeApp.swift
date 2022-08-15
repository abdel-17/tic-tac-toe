import SwiftUI

@main
struct TicTacToeApp: App {
    /// A value to toggle between the system look,
    /// light mode, and dark mode.
    @AppStorage("appearance") var appearance = Appearance.system
    
    /// The difficulty of the game's AI.
    @AppStorage("difficulty") var difficulty = TicTacToe.Difficulty.medium
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 400, idealWidth: 400,
                       minHeight: 400, idealHeight: 400)
            #endif
        }
        #if os(macOS)
        .commands {
            CommandMenu("CPU Difficulty") {
                DifficultyPicker()
                    .pickerStyle(.inline)
                    // Hide the label.
                    .labelStyle(.iconOnly)
            }
            CommandMenu("Appearance") {
                AppearancePicker()
                    .pickerStyle(.inline)
                    // Hide the label.
                    .labelStyle(.iconOnly)
            }
        }
        #endif
    }
}
