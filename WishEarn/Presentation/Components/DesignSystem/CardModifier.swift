import SwiftUI

struct CardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.lg
    var radius: CGFloat = AppRadius.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                AppColors.elevated,
                in: RoundedRectangle(cornerRadius: radius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppColors.separator, lineWidth: 1)
            )
            // Editorial Paper builds depth with hairlines and spacing, not
            // shadows; the card keeps a single 1pt rule.

    }
}

extension View {
    func appCard(
        padding: CGFloat = AppSpacing.lg,
        radius: CGFloat = AppRadius.lg
    ) -> some View {
        modifier(CardModifier(padding: padding, radius: radius))
    }
}

#Preview("Card — Light") {
    CardPreview()
        .preferredColorScheme(.light)
}

#Preview("Card — Dark") {
    CardPreview()
        .preferredColorScheme(.dark)
}

private struct CardPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Kindle Paperwhite")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text("已完成 2 / 3 项条件")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
    }
}
