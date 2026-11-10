import SwiftUI
import UIKit

enum AppColors {
    // MARK: Canvas and surfaces

    static let canvas = Color.dynamic(light: 0xF6F4F0, dark: 0x0D1516)
    static let surface = Color.dynamic(light: 0xFCFBF8, dark: 0x172021)
    static let surfaceSecondary = Color.dynamic(light: 0xE4ECE7, dark: 0x223031)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x161B1C, dark: 0xF1F5F3)
    // Light values are tuned so normal-size supporting text still meets
    // 4.5:1 contrast on canvas and surface.
    static let textSecondary = Color.dynamic(light: 0x5A6868, dark: 0xB7C5C3)
    static let textTertiary = Color.dynamic(light: 0x637271, dark: 0x8FA19F)

    // MARK: Action and state

    // Deep petrol teal in light mode, eucalyptus mint in dark mode. The light
    // accent is dark enough for text; the dark accent takes dark labels.
    static let accent = Color.dynamic(light: 0x194E57, dark: 0x7ECFC3)
    static let accentSoft = Color.dynamic(light: 0xDDEAE6, dark: 0x1A3737)
    static let onAccent = Color.dynamic(light: 0xFFFFFF, dark: 0x0D1516)
    static let success = Color.dynamic(light: 0x2E7A55, dark: 0x78C69A)
    static let warning = Color.dynamic(light: 0x8E641F, dark: 0xD8B36B)
    static let danger = Color.dynamic(light: 0xB14B46, dark: 0xE88B85)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xE3E5E0, dark: 0x2A3838)
    static let progressTrack = Color.dynamic(light: 0xE5ECE8, dark: 0x2A3838)

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
