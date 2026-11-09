import SwiftUI
import UIKit

enum AppColors {
    // MARK: Canvas and surfaces

    static let canvas = Color.dynamic(light: 0xF3F8F8, dark: 0x0C1517)
    static let surface = Color.dynamic(light: 0xFCFEFE, dark: 0x152225)
    static let surfaceSecondary = Color.dynamic(light: 0xE3EFF1, dark: 0x1F3237)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x142628, dark: 0xEDF6F8)
    // Light values are tuned so normal-size supporting text still meets
    // 4.5:1 contrast on canvas and surface.
    static let textSecondary = Color.dynamic(light: 0x50686C, dark: 0xB4C8CD)
    static let textTertiary = Color.dynamic(light: 0x5D7478, dark: 0x8BA2A8)

    // MARK: Action and state

    // Deep lagoon teal in light mode, bright aqua in dark mode. The light
    // accent is dark enough for text; the dark accent takes dark labels.
    static let accent = Color.dynamic(light: 0x0C6F7A, dark: 0x6FD3D8)
    static let accentSoft = Color.dynamic(light: 0xD7EEF2, dark: 0x13383F)
    static let onAccent = Color.dynamic(light: 0xFFFFFF, dark: 0x0C1517)
    static let success = Color.dynamic(light: 0x2E7D4F, dark: 0x72C995)
    static let warning = Color.dynamic(light: 0x94601E, dark: 0xDDB26B)
    static let danger = Color.dynamic(light: 0xB94A45, dark: 0xED8C86)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xD8E6E9, dark: 0x293C41)
    static let progressTrack = Color.dynamic(light: 0xE1EEF1, dark: 0x293C41)

    // MARK: Compatibility aliases
    //
    // Existing screens still use the pre-Phase-2 names. New components should
    // use the semantic names above; pages migrate as they are redesigned.

    static let background = canvas
    static let primary = accent
    static let primarySoft = accentSoft
    static let border = separator
}

enum AppSpacing {
    /// Legacy fine adjustment retained for existing layouts.
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32

    /// Standard horizontal screen inset from DESIGN_SYSTEM.md.
    static let screenInset: CGFloat = 20
    /// Hero-level breathing room.
    static let hero: CGFloat = 40
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 26
    static let pill: CGFloat = 999
}

enum AppLayout {
    static let touchTarget: CGFloat = 44
    static let buttonHeight: CGFloat = 52
}

enum AppTypography {
    /// Editorial serif display, used for hero wish titles and key empty states.
    static let display = Font.system(.largeTitle, design: .serif).weight(.semibold)
    static let largeTitle = Font.system(.largeTitle).weight(.semibold)
    static let title = Font.system(.title2).weight(.semibold)
    static let headline = Font.system(.headline).weight(.semibold)
    static let body = Font.system(.body)
    static let callout = Font.system(.callout)
    static let caption = Font.system(.caption)
    static let caption2 = Font.system(.caption2)
    static let footnote = Font.system(.footnote)
}

enum AppElevation {
    static let cardColor = Color.black.opacity(0.035)
    static let cardRadius: CGFloat = 8
    static let cardY: CGFloat = 4
}

enum AppMotion {
    static let standard = Animation.easeInOut(duration: 0.22)
    static let quick = Animation.easeInOut(duration: 0.18)
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
        background(AppColors.canvas.ignoresSafeArea())
    }
}
