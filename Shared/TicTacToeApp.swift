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
        .commands {
            CommandMenu("Appearance") {
                AppearancePicker()
                    .pickerStyle(.inline)
                    // Hide the label. The command menu's label is sufficient.
                    .labelStyle(.iconOnly)
            }
        }
    }
}
