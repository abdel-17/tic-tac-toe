import SwiftUI

@main
struct TicTacToeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 350, minHeight: 350)
            #endif
        }
        .commands {
            // For customizing the toolbar on macOS.
            ToolbarCommands()
        }
    }
}
