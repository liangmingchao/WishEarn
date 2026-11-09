import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String
    var retryTitle: String = "重试"
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(AppColors.danger)
                .frame(
                    width: AppLayout.touchTarget,
                    height: AppLayout.touchTarget
                )
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let onRetry {
                Button(retryTitle, action: onRetry)
                    .buttonStyle(.appSecondary)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview("Error — Light") {
    ErrorStatePreview()
        .preferredColorScheme(.light)
}

#Preview("Error — Dark") {
    ErrorStatePreview()
        .preferredColorScheme(.dark)
}

private struct ErrorStatePreview: View {
    var body: some View {
        ErrorStateView(
            title: "读取数据失败",
            message: "请稍后重试。你的本地数据没有被修改。",
            onRetry: {}
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
    }
}
