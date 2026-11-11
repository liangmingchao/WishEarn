import SwiftUI
import UIKit

/// Small uppercase-ish label used above editorial page titles.
struct KickerText: View {
    let text: String
    var color: Color = AppColors.primary
    var tracking: CGFloat = 1.2

    var body: some View {
        Text(text)
            .font(AppTypography.kicker)
            .tracking(tracking)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .accessibilityHidden(true)
    }
}

/// Serif section title with an optional quiet detail and sage sparkle.
struct EditorialSectionHeader: View {
    let title: String
    var detail: String?
    var showsSparkle: Bool = true

    init(title: String, detail: String? = nil, showsSparkle: Bool = true) {
        self.title = title
        self.detail = detail
        self.showsSparkle = showsSparkle
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.editorialTitle)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let detail {
                Text(detail)
                    .font(AppTypography.caption.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.sm)

            if showsSparkle {
                Image(systemName: "sparkle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Reusable wish photo surface with a themed placeholder. The image is
/// cropped to fill the caller-provided frame; the placeholder is a quiet
/// gradient plus a line symbol, never a fake photograph.
struct WishPhotoView: View {
    let imageData: Data?
    let theme: WishTheme
    var cornerRadius: CGFloat = AppRadius.card
    var iconSize: CGFloat = 34

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.softTint, theme.container],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "photo")
                .font(.system(size: iconSize, weight: .light))
                .foregroundStyle(theme.onSoftTint)

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
        .accessibilityHidden(true)
    }
}

/// Card press feedback: a light dim plus a very small scale change. The scale
/// is skipped when Reduce Motion is on.
struct PressableCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed && !reduceMotion ? 0.985 : 1
            )
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(AppMotion.quick, value: configuration.isPressed)
    }
}

/// Button press feedback for chips and small controls; opacity only, so it is
/// always Reduce Motion safe.
struct PressableChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.78 : 1)
            .animation(AppMotion.quick, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableCardButtonStyle {
    static var pressableCard: PressableCardButtonStyle {
        PressableCardButtonStyle()
    }
}

extension ButtonStyle where Self == PressableChipButtonStyle {
    static var pressableChip: PressableChipButtonStyle {
        PressableChipButtonStyle()
    }
}

#Preview("Editorial components — Light") {
    EditorialComponentsPreview()
        .preferredColorScheme(.light)
}

#Preview("Editorial components — Dark") {
    EditorialComponentsPreview()
        .preferredColorScheme(.dark)
}

private struct EditorialComponentsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            KickerText(text: "心愿手账")
            EditorialSectionHeader(title: "其他心愿", detail: "4")
            WishPhotoView(imageData: nil, theme: .sage)
                .frame(height: 140)
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
