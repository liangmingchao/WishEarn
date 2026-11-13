import SwiftUI

/// A deterministic decorative theme for a wish.
///
/// The theme is derived from the wish UUID so a wish keeps the same color
/// across launches without adding a persisted model field. Decorative colors
/// are only used for small marks, placeholder washes, and icon plates; the
/// paired `onTint` color is contrast-tested for any medium that carries text.
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

    var tint: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0xF2DFB7, dark: 0x4A3E24)
        case .mint:
            return Color.dynamic(light: 0xCFE3D3, dark: 0x2A3A2F)
        case .sky:
            return Color.dynamic(light: 0xCFE0EC, dark: 0x26333C)
        case .blush:
            return Color.dynamic(light: 0xF0D5CF, dark: 0x3C2B28)
        case .lavender:
            return Color.dynamic(light: 0xDDD7E8, dark: 0x332F3D)
        case .peach:
            return Color.dynamic(light: 0xF3D9C4, dark: 0x3E3025)
        }
    }

    /// Foreground for text or icons placed on a solid theme tint.
    var onTint: Color {
        Color.dynamic(light: 0x23281F, dark: 0xF2EEE4)
    }

    /// Larger placeholder washes use a deliberately mixed surface instead of
    /// opacity, which would turn muddy over the dark canvas.
    var softTint: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0xFAF0D6, dark: 0x302818)
        case .mint:
            return Color.dynamic(light: 0xE6F1E8, dark: 0x1E2A23)
        case .sky:
            return Color.dynamic(light: 0xE6F0F6, dark: 0x1D272E)
        case .blush:
            return Color.dynamic(light: 0xF9E7E3, dark: 0x2C2020)
        case .lavender:
            return Color.dynamic(light: 0xEEEBF5, dark: 0x262330)
        case .peach:
            return Color.dynamic(light: 0xFBEBDF, dark: 0x2E241C)
        }
    }

    var onSoftTint: Color {
        switch self {
        case .butter:
            return Color.dynamic(light: 0x4A3E24, dark: 0xF2DFB7)
        case .mint:
            return Color.dynamic(light: 0x2A3A2F, dark: 0xCFE3D3)
        case .sky:
            return Color.dynamic(light: 0x26333C, dark: 0xCFE0EC)
        case .blush:
            return Color.dynamic(light: 0x3C2B28, dark: 0xF0D5CF)
        case .lavender:
            return Color.dynamic(light: 0x332F3D, dark: 0xDDD7E8)
        case .peach:
            return Color.dynamic(light: 0x3E3025, dark: 0xF3D9C4)
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

/// A monogram plate used when a wish has no photograph yet. It keeps the
/// cover feeling intentional instead of showing a broken-image icon.
struct WishMonogramPlate: View {
    let wish: Wish
    let theme: WishTheme
    var scale: CGFloat = 1

    var body: some View {
        ZStack {
            theme.softTint

            RadialGradient(
                colors: [
                    theme.onSoftTint.opacity(0.10),
                    theme.onSoftTint.opacity(0)
                ],
                center: .topTrailing,
                startRadius: 2,
                endRadius: 160 * scale
            )

            Text(monogram)
                .font(.system(size: 92 * scale, weight: .semibold, design: .serif))
                .foregroundStyle(theme.onSoftTint.opacity(0.18))
                .offset(x: 34 * scale, y: 40 * scale)
                .accessibilityHidden(true)
        }
    }

    private var monogram: String {
        guard let first = wish.title.first else { return "愿" }
        return String(first)
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
                        .foregroundStyle(theme.onTint)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            theme.tint,
                            in: RoundedRectangle(
                                cornerRadius: AppRadius.sm,
                                style: .continuous
                            )
                        )
                }
            }
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
