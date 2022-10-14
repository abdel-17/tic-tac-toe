import SwiftUI

@main
struct TicTacToeApp: App {
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
