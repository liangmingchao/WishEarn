import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String
    var retryTitle: String = "重试"
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(AppColors.danger)

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)

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
