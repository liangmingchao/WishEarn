import SwiftUI
import UIKit

enum AppColors {
    // MARK: Canvas and surfaces

    /// Base canvas. The editorial pages render `EditorialBackground` (a very
    /// light cream-to-lilac wash); this solid value remains the fallback for
    /// surfaces that must not sit on the gradient.
    static let canvas = Color.dynamic(light: 0xFFF9F1, dark: 0x171725)
    static let canvasTop = Color.dynamic(light: 0xFFF9F1, dark: 0x171725)
    static let canvasBottom = Color.dynamic(light: 0xF5F0FF, dark: 0x1B1928)
    static let surface = Color.dynamic(light: 0xFFFFFF, dark: 0x222235)
    static let elevated = Color.dynamic(light: 0xFFFDF9, dark: 0x2C2B42)
    static let surfaceSecondary = Color.dynamic(light: 0xF7EFE5, dark: 0x2A293D)

    // MARK: Decorative glows
    //
    // Only used inside `EditorialBackground`, at low opacity and behind all
    // content. They never carry text.

    static let glowButter = Color.dynamic(light: 0xFFD66E, dark: 0xF6D57B)
    static let glowMint = Color.dynamic(light: 0xA8E3CF, dark: 0x9BDFC7)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x2E3040, dark: 0xF7F3FF)
    // Secondary and tertiary text are tuned to pass 4.5:1 on the canvas
    // gradient endpoints as well as surface and elevated surfaces.
    static let textSecondary = Color.dynamic(light: 0x6A6878, dark: 0xC2BED2)
    static let textTertiary = Color.dynamic(light: 0x6C6978, dark: 0xA19CB5)

    // MARK: Brand and action

    static let primary = Color.dynamic(light: 0x6554C0, dark: 0xA99AFF)
    static let primaryPressed = Color.dynamic(light: 0x5142A8, dark: 0x8F7EE8)
    static let primarySoft = Color.dynamic(light: 0xEFEBFF, dark: 0x352F55)
    static let onPrimary = Color.dynamic(light: 0xFFFFFF, dark: 0x171725)

    /// Brand action gradient. Both endpoints are contrast-tested against
    /// `onPrimary`; the start is deliberately darker than the raw reference
    /// violet so white label text keeps a safe 4.5:1 margin.
    static let primaryGradientStart = Color.dynamic(light: 0x7060CE, dark: 0xB7AAFF)
    static let primaryGradientEnd = Color.dynamic(light: 0x6554C0, dark: 0x9C8CF5)

    /// Secondary emphasis. Coral is a decorative/emphasis fill; use
    /// `coralText` for coral-colored text on light surfaces.
    static let coral = Color.dynamic(light: 0xFF806B, dark: 0xFF9A86)
    static let coralSoft = Color.dynamic(light: 0xFFE6E0, dark: 0x4B2A2E)
    static let coralText = Color.dynamic(light: 0xB5412F, dark: 0xFF9A86)
    static let onCoral = Color.dynamic(light: 0x2E3040, dark: 0x171725)

    // MARK: Semantic state

    static let success = Color.dynamic(light: 0x2F7F57, dark: 0x7BD3A6)
    static let successSoft = Color.dynamic(light: 0xE7F4ED, dark: 0x1F3A2C)
    static let warning = Color.dynamic(light: 0xA06017, dark: 0xE5B86E)
    static let danger = Color.dynamic(light: 0xC24751, dark: 0xFF9AA5)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xECE4DA, dark: 0x3A3852)
    static let progressTrack = Color.dynamic(light: 0xF0E8DE, dark: 0x38364E)

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
    static let screenInset: CGFloat = 20
    /// Hero-level breathing room.
    static let hero: CGFloat = 40
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let card: CGFloat = 22
    static let xl: CGFloat = 26
    static let xxl: CGFloat = 30
    static let pill: CGFloat = 999
}

enum AppLayout {
    static let touchTarget: CGFloat = 44
    static let buttonHeight: CGFloat = 52
    static let primaryButtonHeight: CGFloat = 54
}

enum AppTypography {
    /// Editorial serif display, used for page and wish titles.
    static let display = Font.system(.largeTitle, design: .serif).weight(.bold)
    /// Serif section title, one step below the display.
    static let editorialTitle = Font.system(.title2, design: .serif).weight(.semibold)
    /// Serif card title used inside themed cards.
    static let editorialHeadline = Font.system(.title3, design: .serif).weight(.semibold)
    static let largeTitle = Font.system(.largeTitle).weight(.semibold)
    static let title = Font.system(.title2).weight(.semibold)
    static let headline = Font.system(.headline).weight(.semibold)
    static let body = Font.system(.body)
    static let callout = Font.system(.callout)
    static let caption = Font.system(.caption)
    static let caption2 = Font.system(.caption2)
    static let footnote = Font.system(.footnote)
    /// Small editorial kicker, e.g. “心愿手账 / 今天可以推进”.
    static let kicker = Font.system(.caption).weight(.semibold)
    /// Rounded, monospaced numerals for counters and progress values.
    static let metric = Font.system(.title3, design: .rounded)
        .weight(.bold)
        .monospacedDigit()
}

enum AppElevation {
    static let cardColor = Color.black.opacity(0.055)
    static let cardRadius: CGFloat = 14
    static let cardY: CGFloat = 6
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

/// Warm paper canvas with two very quiet color glows. The glows sit behind
/// all content and never carry text, so every text/background pair keeps its
/// verified contrast on the solid endpoints of the gradient.
struct EditorialBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.canvasTop, AppColors.canvasBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    AppColors.glowButter.opacity(colorScheme == .dark ? 0.10 : 0.30),
                    .clear
                ],
                center: UnitPoint(x: 1.04, y: -0.04),
                startRadius: 10,
                endRadius: 340
            )

            RadialGradient(
                colors: [
                    AppColors.glowMint.opacity(colorScheme == .dark ? 0.10 : 0.22),
                    .clear
                ],
                center: UnitPoint(x: -0.08, y: 0.92),
                startRadius: 10,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(EditorialBackground())
    }
}
