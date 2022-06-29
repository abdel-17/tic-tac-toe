import SwiftUI

@main
struct TicTacToeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 350,
                       minHeight: 400)
            #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
