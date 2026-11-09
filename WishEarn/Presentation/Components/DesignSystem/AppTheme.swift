import SwiftUI
import UIKit

enum AppColors {
    // MARK: Canvas and surfaces

    static let canvas = Color.dynamic(light: 0xF7F4EF, dark: 0x151412)
    static let surface = Color.dynamic(light: 0xFFFEFC, dark: 0x211F1C)
    static let surfaceSecondary = Color.dynamic(light: 0xEEEAE3, dark: 0x2B2824)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x282521, dark: 0xF4F0E9)
    // Light values are darkened from the initial design targets so normal-size
    // supporting text still meets 4.5:1 contrast on canvas and surface.
    static let textSecondary = Color.dynamic(light: 0x5F5A52, dark: 0xB9B2A8)
    static let textTertiary = Color.dynamic(light: 0x746F66, dark: 0x8E877E)

    // MARK: Action and state

    // Light accent is darkened from #B85F3D for text contrast; the dark accent
    // is intentionally light enough to use dark labels on top.
    static let accent = Color.dynamic(light: 0x9C4A2E, dark: 0xE08A65)
    static let accentSoft = Color.dynamic(light: 0xF1DED4, dark: 0x422B22)
    static let onAccent = Color.dynamic(light: 0xFFFFFF, dark: 0x151412)
    static let success = Color.dynamic(light: 0x397B5B, dark: 0x76B994)
    static let warning = Color.dynamic(light: 0x94601E, dark: 0xD9A65C)
    static let danger = Color.dynamic(light: 0xB94A45, dark: 0xE47C75)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xE4DED5, dark: 0x39352F)
    static let progressTrack = Color.dynamic(light: 0xEAE4DC, dark: 0x39352F)

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
