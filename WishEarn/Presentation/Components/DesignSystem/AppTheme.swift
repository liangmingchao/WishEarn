import SwiftUI
import UIKit

/// Daylight Ledger — the visual language for WishEarn 2.0.
///
/// Warm paper as the canvas, pine green as the single action color, and amber
/// reserved for the moment a reward is unlocked. Tokens keep their historical
/// names so every screen migrates by adopting new values instead of new APIs.
enum AppColors {
    // MARK: Canvas and surfaces

    static let canvas = Color.dynamic(light: 0xFAF6EE, dark: 0x131511)
    static let surface = Color.dynamic(light: 0xFFFFFF, dark: 0x1B1E19)
    static let elevated = Color.dynamic(light: 0xFFFDF8, dark: 0x23261F)
    static let surfaceSecondary = Color.dynamic(light: 0xF2EADD, dark: 0x23261F)

    // MARK: Text

    static let textPrimary = Color.dynamic(light: 0x1D211C, dark: 0xF2EEE4)
    // Secondary and tertiary text are tuned to pass 4.5:1 on canvas, surface,
    // and elevated surfaces in both appearances.
    static let textSecondary = Color.dynamic(light: 0x585F57, dark: 0xB6BCB0)
    static let textTertiary = Color.dynamic(light: 0x6B7168, dark: 0x939A8E)

    // MARK: Brand and action

    static let primary = Color.dynamic(light: 0x2C5B4A, dark: 0x8FC0A4)
    static let primaryPressed = Color.dynamic(light: 0x234A3C, dark: 0xA5D2B7)
    static let primarySoft = Color.dynamic(light: 0xE3EDE6, dark: 0x222E27)
    static let onPrimary = Color.dynamic(light: 0xFFFBF0, dark: 0x131511)

    /// Reward emphasis. Amber is an accent for unlocked / celebration states,
    /// never a general-purpose action color.
    static let coral = Color.dynamic(light: 0x8A5514, dark: 0xE3B26B)
    static let coralSoft = Color.dynamic(light: 0xF6E7C9, dark: 0x32281B)
    static let coralText = Color.dynamic(light: 0x7C4A0F, dark: 0xE3B26B)
    static let onCoral = Color.dynamic(light: 0xFFFBF0, dark: 0x131511)

    static let amber = coral
    static let amberSoft = coralSoft
    static let amberText = coralText

    // MARK: Semantic state

    static let success = Color.dynamic(light: 0x2F7A56, dark: 0x7FBF9B)
    static let successSoft = Color.dynamic(light: 0xE3EFE7, dark: 0x1E2E24)
    static let warning = Color.dynamic(light: 0x8A5514, dark: 0xE3B26B)
    static let danger = Color.dynamic(light: 0x9C3B26, dark: 0xE08C74)

    // MARK: Structure

    static let separator = Color.dynamic(light: 0xE8DFD1, dark: 0x2D322A)
    static let separatorSoft = Color.dynamic(light: 0xF0E9DC, dark: 0x242920)
    static let progressTrack = Color.dynamic(light: 0xEDE4D6, dark: 0x2A2F27)

    // MARK: Imagery

    /// Text and icons placed on top of photographs or the hero scrim.
    static let onImage = Color.dynamic(light: 0xFFF9EC, dark: 0xFFF9EC)
    static let imageScrim = Color.dynamic(light: 0x12140F, dark: 0x0B0C08)
    /// A solid, ink-dark surface used by the unlock ceremony.
    static let ceremony = Color.dynamic(light: 0x16241D, dark: 0x0F1511)

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
    /// 8pt-grid rhythm used by the refreshed screens.
    static let gutter: CGFloat = 16
    static let section: CGFloat = 28
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 26
    static let pill: CGFloat = 999

    /// Cards in the refreshed layout sit on an 18pt corner.
    static let card: CGFloat = 18
    static let thumbnail: CGFloat = 12
}

enum AppLayout {
    static let touchTarget: CGFloat = 44
    static let buttonHeight: CGFloat = 52
    /// Featured wish cover ratio used on the home screen.
    static let featuredAspectRatio: CGFloat = 1.42
    /// Compact wish row thumbnail.
    static let thumbnailSize: CGFloat = 68
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

    // MARK: Daylight Ledger

    /// Page title — serif, scaled with Dynamic Type.
    static let pageTitle = Font.system(.largeTitle, design: .serif).weight(.semibold)
    /// Wish name inside a card or a detail hero.
    static let wishTitle = Font.system(.title2, design: .serif).weight(.semibold)
    static let wishTitleCompact = Font.system(.headline, design: .serif).weight(.semibold)
    /// Monospaced eyebrow for dates and labels.
    static let eyebrow = Font.system(.caption, design: .monospaced).weight(.medium)
    /// Tabular figures keep progress numbers from jumping.
    static let number = Font.system(.title3, design: .rounded).weight(.semibold)
    static let sectionTitle = Font.system(.subheadline).weight(.semibold)
}

enum AppElevation {
    static let cardColor = Color.black.opacity(0.035)
    static let cardRadius: CGFloat = 8
    static let cardY: CGFloat = 4

    /// Soft paper shadow: barely visible lift, no glossy bevel.
    static let shadowColor = Color.dynamic(light: 0x241F14, dark: 0x000000)
    static let shadowOpacity: Double = 0.10
    static let shadowRadius: CGFloat = 18
    static let shadowY: CGFloat = 10
}

enum AppMotion {
    static let standard = Animation.easeInOut(duration: 0.22)
    static let quick = Animation.easeInOut(duration: 0.18)
    static let sheet = Animation.spring(response: 0.38, dampingFraction: 0.86)
    static let ceremony = Animation.spring(response: 0.62, dampingFraction: 0.82)
}

extension Color {
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
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

    /// A single soft paper lift shared by cards across the app.
    func appPaperShadow() -> some View {
        shadow(
            color: AppElevation.shadowColor.opacity(AppElevation.shadowOpacity),
            radius: AppElevation.shadowRadius,
            x: 0,
            y: AppElevation.shadowY
        )
    }
}
