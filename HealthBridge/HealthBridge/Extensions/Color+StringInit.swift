import SwiftUI

extension Color {
    /// Create a Color from a string name (e.g., "blue", "red", "green")
    /// This is used to convert the string color names from model types to actual SwiftUI Colors
    static func fromName(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "mint": return .mint
        case "teal": return .teal
        case "cyan": return .cyan
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray", "grey": return .gray
        case "black": return .black
        case "white": return .white
        case "primary": return .primary
        case "secondary": return .secondary
        default:
            // Fallback to gray for unknown colors
            return .gray
        }
    }
}
