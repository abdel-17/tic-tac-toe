import SwiftUI

@main
struct TicTacToeApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            NavigationView {
                ContentView()
            }
            .navigationViewStyle(.stack)
            #elseif os(macOS)
            ContentView()
                .frame(minWidth: 400, idealWidth: 400,
                       minHeight: 400, idealHeight: 400)
            #endif
        }
    }
}
