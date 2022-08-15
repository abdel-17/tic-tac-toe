import SwiftUI

/// An enum of app appearance modes.
enum Appearance: String, CaseIterable, Identifiable {
    /// Light mode.
    case light
    
    /// Dark mode.
    case dark
    
    /// Match the system.
    case system
    
    var id: Self { self }
    
    /// The preferred color scheme
    /// of this appearance.
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
