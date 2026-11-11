import SwiftUI
import UIKit

/// A quiet "paper and sage" palette. The canvas is warm paper, text is ink,
/// and a single deep sage green carries actions. A muted clay accent is used
/// sparingly for small editorial marks. Wish photos and wish themes provide
/// the remaining color, so the interface itself stays calm.
enum AppColors {
    // MARK: Canvas and surfaces

    static let canvas = Color.dynamic(light: 0xFAF8F3, dark: 0x171815)
    static let canvasTop = Color.dynamic(light: 0xFAF8F3, dark: 0x171815)
    static let canvasBottom = Color.dynamic(light: 0xF3F0E8, dark: 0x1D1E1A)
    static let surface = Color.dynamic(light: 0xFFFFFF, dark: 0x232420)
    static let elevated = Color.dynamic(light: 0xFFFDF8, dark: 0x2B2C27)
    static let surfaceSecondary = Color.dynamic(light: 0xF1EEE6, dark: 0x2E2F2A)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x24251F, dark: 0xF3F1E9)
    static let textSecondary = Color.dynamic(light: 0x5E6056, dark: 0xC3C0B5)
    static let textTertiary = Color.dynamic(light: 0x67695F, dark: 0xA7A498)

    // MARK: Brand and action

    static let primary = Color.dynamic(light: 0x3C6252, dark: 0x9CC6B1)
    static let primaryPressed = Color.dynamic(light: 0x2E4D40, dark: 0x87B29D)
    static let primarySoft = Color.dynamic(light: 0xE7EFE9, dark: 0x293A32)
    static let onPrimary = Color.dynamic(light: 0xFFFFFF, dark: 0x14201A)

    /// A single warm accent, used only for small editorial marks. Large
    /// surfaces stay neutral.
    static let clay = Color.dynamic(light: 0xA25C42, dark: 0xD99C82)
    static let claySoft = Color.dynamic(light: 0xF3E7DF, dark: 0x3A2B25)
    static let clayText = Color.dynamic(light: 0x84442E, dark: 0xE7B39B)
    static let onClay = Color.dynamic(light: 0xFFFFFF, dark: 0x17110E)

    // MARK: Semantic state

    static let success = Color.dynamic(light: 0x2F6B4F, dark: 0x7BC6A3)
    static let successSoft = Color.dynamic(light: 0xE6F0EA, dark: 0x1E3A2D)
    static let warning = Color.dynamic(light: 0x8A5A18, dark: 0xE0B368)
    static let danger = Color.dynamic(light: 0xB4454E, dark: 0xF09AA3)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xE7E2D8, dark: 0x393A34)
    static let progressTrack = Color.dynamic(light: 0xECE7DD, dark: 0x363732)

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
    static let cardColor = Color.black.opacity(0.04)
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

/// Warm paper canvas, rendered as one quiet vertical gradient. No decorative
/// color glows: photos and the single sage accent carry the color.
struct EditorialBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AppColors.canvasTop, AppColors.canvasBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(EditorialBackground())
    }
}
