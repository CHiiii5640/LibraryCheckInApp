import SwiftUI

extension Color {
    static let appPrimary = Color("PrimaryColor")
    static let appSuccess = Color("SuccessColor")
    static let appWarning = Color("WarningColor")
    static let appDanger = Color("DangerColor")
    static let appBackground = Color("BackgroundColor")
    static let cardBackground = Color("CardBackground")
}

struct AppTheme {
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let cardShadow = Shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
} 