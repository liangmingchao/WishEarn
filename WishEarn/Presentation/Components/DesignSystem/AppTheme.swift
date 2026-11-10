import SwiftUI
import UIKit

enum AppColors {
    // MARK: Canvas and surfaces
    //
    // Editorial Paper palette: warm paper canvas, ink typography, a single
    // mint accent for status. Surfaces stay close to the canvas so the layout
    // relies on hairlines and spacing instead of card elevation.

    static let canvas = Color.dynamic(light: 0xFAF6EF, dark: 0x14120F)
    static let surface = Color.dynamic(light: 0xFFFDF8, dark: 0x1D1A16)
    static let elevated = Color.dynamic(light: 0xFFFDF8, dark: 0x221E19)
    static let surfaceSecondary = Color.dynamic(light: 0xF2EBDF, dark: 0x26221C)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x16120E, dark: 0xF7F1E6)
    // Secondary and tertiary text are tuned to pass 4.5:1 on canvas, surface,
    // and elevated surfaces in both appearances.
    static let textSecondary = Color.dynamic(light: 0x6B6459, dark: 0xC4BCAE)
    static let textTertiary = Color.dynamic(light: 0x767063, dark: 0xA79E90)

    // MARK: Brand and action
    //
    // Ink is the only action color: one filled capsule per screen. Mint carries
    // status and progress, never the primary action.

    static let primary = Color.dynamic(light: 0x191512, dark: 0xF2ECDF)
    static let primaryPressed = Color.dynamic(light: 0x2E2823, dark: 0xD8D0C0)
    static let primarySoft = Color.dynamic(light: 0xDEEDE3, dark: 0x24352C)
    static let onPrimary = Color.dynamic(light: 0xFFFCF5, dark: 0x16120E)

    /// Status chip: mint fill, deep green label.
    static let chipFill = primarySoft
    static let chipText = Color.dynamic(light: 0x2B6A4D, dark: 0x9BDFC7)
    static let chipTextMuted = Color.dynamic(light: 0x456F5B, dark: 0x7FBFA4)

    /// Secondary emphasis. Coral is a decorative/emphasis fill; use
    /// `coralText` for coral-colored text on light surfaces.
    static let coral = Color.dynamic(light: 0xEE8A72, dark: 0xF0957E)
    static let coralSoft = Color.dynamic(light: 0xFBE6DC, dark: 0x3A2A24)
    static let coralText = Color.dynamic(light: 0xAC4A34, dark: 0xF0A08A)
    static let onCoral = Color.dynamic(light: 0x16120E, dark: 0x16120E)

    // MARK: Semantic state

    static let success = Color.dynamic(light: 0x2B6A4D, dark: 0x7BD3A6)
    static let successSoft = Color.dynamic(light: 0xDEEDE3, dark: 0x24352C)
    static let warning = Color.dynamic(light: 0x8A5210, dark: 0xE5B86E)
    static let danger = Color.dynamic(light: 0xB23B45, dark: 0xFF9AA5)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xE9E1D4, dark: 0x332F27)
    static let progressTrack = Color.dynamic(light: 0xECE4D6, dark: 0x36322A)

    // MARK: Compatibility aliases
    //
    // Existing screens still use the pre-refresh names. New components should
    // use the semantic names above; pages migrate as they are redesigned.

    static let accent = primary
    static let accentSoft = primarySoft
    static let onAccent = onPrimary
    static let background = canvas
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
    static let screenInset: CGFloat = 24
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
    static let buttonHeight: CGFloat = 56
    /// Editorial hero imagery uses a 4:3 crop.
    static let heroAspectRatio: CGFloat = 4.0 / 3.0
}

enum AppTypography {
    /// Ink display type: heavy grotesque, tight tracking. Used for the hero
    /// wish title, page headlines, and key empty states.
    static let display = Font.system(.largeTitle).weight(.semibold)
    static let largeTitle = Font.system(.largeTitle).weight(.semibold)
    static let title = Font.system(.title2).weight(.semibold)
    static let headline = Font.system(.headline).weight(.semibold)
    static let body = Font.system(.body)
    static let callout = Font.system(.callout)
    static let caption = Font.system(.caption)
    static let caption2 = Font.system(.caption2)
    static let footnote = Font.system(.footnote)

    /// Small uppercase-style label above a section, e.g. “继续这个心愿”.
    static let kicker = Font.system(.caption).weight(.semibold)
    /// Numeric emphasis inside status chips.
    static let chipNumber = Font.system(.title3).weight(.bold)
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
        Color(uiColor: .dynamic(light: light, dark: dark))
    }
}

extension UIColor {
    /// Dynamic color usable by UIKit appearance proxies, which do not accept
    /// SwiftUI colors directly.
    static func dynamic(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        }
    }

    convenience init(rgb: UInt32) {
        let red = CGFloat((rgb >> 16) & 0xFF) / 255
        let green = CGFloat((rgb >> 8) & 0xFF) / 255
        let blue = CGFloat(rgb & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(AppColors.canvas.ignoresSafeArea())
    }
}
