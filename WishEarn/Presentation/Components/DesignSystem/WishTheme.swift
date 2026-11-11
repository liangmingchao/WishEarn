import SwiftUI

/// A deterministic decorative theme for a wish.
///
/// The theme is derived from the wish UUID so a wish keeps the same color
/// across launches without adding a persisted model field.
///
/// Three coordinated roles:
/// - `tint` / `onTint`: small marks, icon plates and stickers.
/// - `softTint` / `onSoftTint`: photo placeholder washes and quiet insets.
/// - `container` / `onContainer`: large themed card surfaces. In light mode
///   the card is the pastel tint with ink text; in dark mode it becomes a
///   deep, desaturated version of the same hue with a light tint text.
///
/// Every `on…` pair is contrast-tested in `DesignSystemTests`.
enum WishTheme: String, CaseIterable, Sendable {
    case butter
    case mint
    case sky
    case blush
    case lavender
    case peach

    static func forWish(_ wish: Wish) -> WishTheme {
        forID(wish.id)
    }

    static func forID(_ id: UUID) -> WishTheme {
        let hex = id.uuidString.replacingOccurrences(of: "-", with: "")
        let seed = UInt64(hex.prefix(12), radix: 16) ?? 0
        return allCases[Int(seed % UInt64(allCases.count))]
    }

    /// Solid decorative accent. Stays pastel in both appearances because it
    /// is paired with a near-black `onTint`.
    var tint: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0xFFD66E, dark: 0xF6D57B)
        case .mint:
            return Color.dynamic(light: 0xA8E3CF, dark: 0x9BDFC7)
        case .sky:
            return Color.dynamic(light: 0xA9D7F2, dark: 0x9CCBEA)
        case .blush:
            return Color.dynamic(light: 0xF6C6D1, dark: 0xF3B9C8)
        case .lavender:
            return Color.dynamic(light: 0xDCD4FF, dark: 0xC9BEFF)
        case .peach:
            return Color.dynamic(light: 0xFFE0D2, dark: 0xF8CBB7)
        }
    }

    /// Foreground for text or icons placed on a solid theme tint.
    var onTint: Color {
        Color.dynamic(light: 0x2E3040, dark: 0x171725)
    }

    /// Larger placeholder washes use a deliberately mixed surface instead of
    /// opacity, which would turn muddy over the dark canvas.
    var softTint: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0xFFF0C7, dark: 0x3A3427)
        case .mint:
            return Color.dynamic(light: 0xDDF3EA, dark: 0x223B33)
        case .sky:
            return Color.dynamic(light: 0xDFEEF9, dark: 0x22343F)
        case .blush:
            return Color.dynamic(light: 0xFBE3E8, dark: 0x3B2B31)
        case .lavender:
            return Color.dynamic(light: 0xEEEAFB, dark: 0x302C45)
        case .peach:
            return Color.dynamic(light: 0xFFF0E8, dark: 0x3B2D27)
        }
    }

    var onSoftTint: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0x2E3040, dark: 0xF6D57B)
        case .mint:
            return Color.dynamic(light: 0x2E3040, dark: 0x9BDFC7)
        case .sky:
            return Color.dynamic(light: 0x2E3040, dark: 0x9CCBEA)
        case .blush:
            return Color.dynamic(light: 0x2E3040, dark: 0xF3B9C8)
        case .lavender:
            return Color.dynamic(light: 0x2E3040, dark: 0xC9BEFF)
        case .peach:
            return Color.dynamic(light: 0x2E3040, dark: 0xF8CBB7)
        }
    }

    /// Large themed card surface.
    var container: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0xFFD66E, dark: 0x3A3427)
        case .mint:
            return Color.dynamic(light: 0xA8E3CF, dark: 0x223B33)
        case .sky:
            return Color.dynamic(light: 0xA9D7F2, dark: 0x22343F)
        case .blush:
            return Color.dynamic(light: 0xF6C6D1, dark: 0x3B2B31)
        case .lavender:
            return Color.dynamic(light: 0xDCD4FF, dark: 0x302C45)
        case .peach:
            return Color.dynamic(light: 0xFFE0D2, dark: 0x3B2D27)
        }
    }

    /// Text and icons on `container`.
    var onContainer: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0x2E3040, dark: 0xF6D57B)
        case .mint:
            return Color.dynamic(light: 0x2E3040, dark: 0x9BDFC7)
        case .sky:
            return Color.dynamic(light: 0x2E3040, dark: 0x9CCBEA)
        case .blush:
            return Color.dynamic(light: 0x2E3040, dark: 0xF3B9C8)
        case .lavender:
            return Color.dynamic(light: 0x2E3040, dark: 0xC9BEFF)
        case .peach:
            return Color.dynamic(light: 0x2E3040, dark: 0xF8CBB7)
        }
    }

    /// Readable theme identity for small text placed on neutral surfaces.
    var labelText: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0x8A6412, dark: 0xF6D57B)
        case .mint:
            return Color.dynamic(light: 0x2B6A4D, dark: 0x9BDFC7)
        case .sky:
            return Color.dynamic(light: 0x2A5E82, dark: 0x9CCBEA)
        case .blush:
            return Color.dynamic(light: 0x9A3C58, dark: 0xF3B9C8)
        case .lavender:
            return Color.dynamic(light: 0x55469C, dark: 0xC9BEFF)
        case .peach:
            return Color.dynamic(light: 0x9A4C2F, dark: 0xF8CBB7)
        }
    }
}

struct WishThemeMark: View {
    let theme: WishTheme
    var width: CGFloat = 28

    var body: some View {
        Capsule()
            .fill(theme.tint)
            .frame(width: width, height: 4)
            .accessibilityHidden(true)
    }
}

struct WishThemeDot: View {
    let theme: WishTheme
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(theme.tint)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// A small sticker used to carry the wish identity over photography without
/// covering the subject. Decorative only.
struct WishThemeSticker: View {
    let theme: WishTheme
    var symbol: String = "sparkles"
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.40, weight: .semibold))
            .foregroundStyle(theme.onTint)
            .frame(width: size, height: size)
            .background(
                theme.tint,
                in: RoundedRectangle(
                    cornerRadius: size * 0.34,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: size * 0.34,
                    style: .continuous
                )
                .stroke(AppColors.surface, lineWidth: 2)
            }
            .accessibilityHidden(true)
    }
}

#Preview("Wish themes — Light") {
    WishThemePreview()
        .preferredColorScheme(.light)
}

#Preview("Wish themes — Dark") {
    WishThemePreview()
        .preferredColorScheme(.dark)
}

private struct WishThemePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            ForEach(WishTheme.allCases, id: \.self) { theme in
                HStack(spacing: AppSpacing.md) {
                    WishThemeMark(theme: theme, width: 42)
                    WishThemeDot(theme: theme, size: 14)
                    Text(theme.rawValue.capitalized)
                        .font(AppTypography.callout)
                        .foregroundStyle(theme.onContainer)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            theme.container,
                            in: RoundedRectangle(
                                cornerRadius: AppRadius.sm,
                                style: .continuous
                            )
                        )
                    WishThemeSticker(theme: theme)
                }
            }
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
