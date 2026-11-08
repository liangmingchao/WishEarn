import SwiftUI
import UIKit

enum AppColors {
    static let background = Color.dynamic(light: 0xFFF9F5, dark: 0x12100F)
    static let surface = Color.dynamic(light: 0xFFFFFF, dark: 0x1E1B19)
    static let surfaceSecondary = Color.dynamic(light: 0xF7EFE9, dark: 0x262220)
    static let primary = Color.dynamic(light: 0xF28C5B, dark: 0xF59B6F)
    static let primarySoft = Color.dynamic(light: 0xFDE7DA, dark: 0x3A251B)
    static let textPrimary = Color.dynamic(light: 0x2B2320, dark: 0xF5EFEA)
    static let textSecondary = Color.dynamic(light: 0x7A6F68, dark: 0xA99C93)
    static let border = Color.dynamic(light: 0xEEE3DB, dark: 0x2E2A27)
    static let success = Color.dynamic(light: 0x4CAF7D, dark: 0x6FCB9A)
    static let warning = Color.dynamic(light: 0xE0A33E, dark: 0xF0BE66)
    static let danger = Color.dynamic(light: 0xD95C5C, dark: 0xEE7B7B)
    static let progressTrack = Color.dynamic(light: 0xF1E6DE, dark: 0x2A2623)
}

enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

enum AppTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let callout = Font.system(.callout, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let caption2 = Font.system(.caption2, design: .rounded)
}

extension Color {
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(AppColors.background.ignoresSafeArea())
    }
}
