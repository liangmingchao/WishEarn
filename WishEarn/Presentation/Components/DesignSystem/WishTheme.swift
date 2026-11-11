import SwiftUI

/// A deterministic, low-saturation decorative theme for a wish.
///
/// The theme is derived from the wish UUID so a wish keeps the same accent
/// across launches without adding a persisted model field. It is deliberately
/// restricted to three muted tones: sage, clay and stone. The theme appears as
/// a small mark or tinted wash, never as a large saturated card.
///
/// Roles:
/// - `tint` / `onTint`: small marks, dots and icon plates.
/// - `softTint` / `onSoftTint`: photo placeholder washes.
/// - `container` / `onContainer`: quiet themed surfaces, such as the detail
///   hero.
/// - `labelText`: readable theme identity on neutral paper surfaces.
///
/// Every `on…` pair is contrast-tested in `DesignSystemTests`.
enum WishTheme: String, CaseIterable, Sendable {
    case sage
    case clay
    case stone

    static func forWish(_ wish: Wish) -> WishTheme {
        forID(wish.id)
    }

    static func forID(_ id: UUID) -> WishTheme {
        let hex = id.uuidString.replacingOccurrences(of: "-", with: "")
        let seed = UInt64(hex.prefix(12), radix: 16) ?? 0
        return allCases[Int(seed % UInt64(allCases.count))]
    }

    /// Solid decorative accent. Paired with a near-black `onTint` in both
    /// appearances so small marks stay readable without becoming loud.
    var tint: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0x9DB9A7, dark: 0x9DB9A7)
        case .clay:
            return Color.dynamic(light: 0xC99A80, dark: 0xC99A80)
        case .stone:
            return Color.dynamic(light: 0xB9B6A8, dark: 0xB2AFA1)
        }
    }

    var onTint: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0x24251F, dark: 0x14150F)
        case .clay:
            return Color.dynamic(light: 0x2A1E18, dark: 0x2A1E18)
        case .stone:
            return Color.dynamic(light: 0x24251F, dark: 0x23241E)
        }
    }

    /// Quiet photo-placeholder wash. Mixed explicitly instead of using
    /// opacity so it does not become muddy over the dark canvas.
    var softTint: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0xE7EFE8, dark: 0x232F29)
        case .clay:
            return Color.dynamic(light: 0xF3E7DF, dark: 0x332721)
        case .stone:
            return Color.dynamic(light: 0xEFEEE7, dark: 0x2B2C27)
        }
    }

    var onSoftTint: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0x24251F, dark: 0xC7DACD)
        case .clay:
            return Color.dynamic(light: 0x24251F, dark: 0xE9D5C9)
        case .stone:
            return Color.dynamic(light: 0x24251F, dark: 0xDEDDD5)
        }
    }

    /// Quiet themed surface, used by the wish detail hero.
    var container: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0xEEF2EA, dark: 0x242F29)
        case .clay:
            return Color.dynamic(light: 0xF6EEE8, dark: 0x302620)
        case .stone:
            return Color.dynamic(light: 0xF2F1EB, dark: 0x2B2C27)
        }
    }

    /// Text and icons on `container`.
    var onContainer: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0x24251F, dark: 0xD6E2D9)
        case .clay:
            return Color.dynamic(light: 0x24251F, dark: 0xE9D5C9)
        case .stone:
            return Color.dynamic(light: 0x24251F, dark: 0xDEDDD5)
        }
    }

    /// Readable theme identity for small text placed on neutral surfaces.
    var labelText: Color {
        switch self {
        case .sage:
            return Color.dynamic(light: 0x3E6654, dark: 0xA9CBB8)
        case .clay:
            return Color.dynamic(light: 0x83452F, dark: 0xDFAC93)
        case .stone:
            return Color.dynamic(light: 0x5A5C53, dark: 0xC0C2B7)
        }
    }
}

/// A short rule that carries the wish's muted theme identity.
struct WishThemeMark: View {
    let theme: WishTheme
    var width: CGFloat = 28
    var height: CGFloat = 4

    var body: some View {
        Capsule()
            .fill(theme.tint)
            .frame(width: width, height: height)
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
                    Text("主题色")
                        .font(AppTypography.caption)
                        .foregroundStyle(theme.labelText)
                }
            }
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
