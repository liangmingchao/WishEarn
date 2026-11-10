import SwiftUI

/// Mint status banner: one number, one sentence, nothing else.
struct StatusChip: View {
    let value: String
    let unit: String
    let caption: String
    var systemImage: String = "sparkle"

    var body: some View {
        HStack(spacing: AppSpacing.sm + 2) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.chipText)
                .accessibilityHidden(true)

            Text(value)
                .font(AppTypography.chipNumber)
                .foregroundStyle(AppColors.chipText)
                .monospacedDigit()
                .tracking(-0.4)

            Text(unit)
                .font(AppTypography.callout.weight(.medium))
                .foregroundStyle(AppColors.chipText)

            Spacer(minLength: AppSpacing.sm)

            Text(caption)
                .font(AppTypography.caption.weight(.medium))
                .foregroundStyle(AppColors.chipTextMuted)
        }
        .padding(.horizontal, AppSpacing.lg + 2)
        .frame(height: 56)
        .background(AppColors.chipFill)
        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(value)\(unit)，\(caption)"))
    }
}

#Preview("Status chip") {
    VStack(spacing: AppSpacing.lg) {
        StatusChip(value: "3", unit: "件小事", caption: "今天可以推进")
        StatusChip(value: "12", unit: "天", caption: "连续记录", systemImage: "flame")
    }
    .padding(AppSpacing.screenInset)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .appScreenBackground()
}
