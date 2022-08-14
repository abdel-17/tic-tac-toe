import SwiftUI

struct ContentView: View {
    /// The appearance mode of this app.
    @AppStorage("appearance") private var appearance = Appearance.system
    
    /// The view model.
    @StateObject private var grid = GameGrid()
    
    var body: some View {
        GeometryReader { proxy in
            // 10% padding.
            GridView(length: 0.8 * min(proxy.size.width, proxy.size.height))
            // Center the grid.
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .navigationTitle(grid.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                RestartButton()
            }
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    extraToolbarControls
                } label: {
                    Label("settings", systemImage: "gear")
                }
            }
            #elseif os(macOS)
            ToolbarItemGroup {
                extraToolbarControls
            }
            #endif
        }
        .preferredColorScheme(appearance.preferredColorScheme)
        .environmentObject(grid)
    }
    
    @ViewBuilder private var extraToolbarControls: some View {
        SwitchGameModeButton()
        DifficultyPicker()
        AppearancePicker(selection: $appearance)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
