import SwiftUI
import Combine

typealias EventPublisher = PassthroughSubject<Void, Never>

struct ContentView : View {
    /// The appearance of the app.
    ///
    /// The user can choose to override the
    /// system look, forcing dark or light mode.
    @AppStorage("appearance") private var appearance = Appearance.system
    
    /// The text presented by the navigation bar on iOS
    /// and the window on macOS.
    @State private var navigationTitle = ""
    
    /// A publisher for sending reset events.
    private let resetPublisher = EventPublisher()
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width, height = geometry.size.height
            TicTacToeGrid(navigationTitle: $navigationTitle,
                          resetPublisher: resetPublisher,
                          // Add 5% padding.
                          length: 0.9 * min(width, height))
            // Center the grid.
            .frame(width: width, height: height)
        }
        .navigationTitle(navigationTitle)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar(id: "actions") {
            ToolbarItem(id: "restart", placement: .primaryAction) {
                RestartButton(resetPublisher: resetPublisher)
            }
            ToolbarItem(id: "mode") {
                SwitchGameModeButton(resetPublisher: resetPublisher)
            }
            ToolbarItem(id: "difficulty") {
                DifficultyPicker()
            }
            // The appearance is changed from a command menu on macOS.
            #if os(iOS)
            ToolbarItem(id: "appearance") {
                AppearancePicker()
            }
            #endif
        }
        .preferredColorScheme(appearance.preferredColorScheme)
        #if os(iOS)
        .wrapInNavigationStack()
        #endif
    }
}

// `NavigationViewStyle.stack` is not available on macOS
// and `NavigationStack` requires iOS 16+ and macOS 13+.
// Can we have some backwards compatibility, Apple?
#if os(iOS)
extension View {
    func wrapInNavigationStack() -> some View {
        NavigationView {
            self
        }
        .navigationViewStyle(.stack)
    }
}
#endif

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
