import SwiftUI

enum AppTheme {
    static let primary = Color(red: 0.18, green: 0.74, blue: 0.42)
    static let primaryDark = Color(red: 0.12, green: 0.58, blue: 0.34)
    static let primaryLight = Color(red: 0.85, green: 0.96, blue: 0.89)
    static let background = Color(red: 0.94, green: 0.98, blue: 0.95)
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.06)
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
