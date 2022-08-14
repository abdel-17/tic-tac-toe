import SwiftUI

/// An enum of app appearance modes.
enum Appearance: String, CaseIterable, Identifiable {
    /// Match the system look.
    case system
    
    /// Light mode.
    case light
    
    /// Dark mode.
    case dark
    
    var id: Self { self }
    
    /// The preferred color scheme
    /// of this appearance.
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
