import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppColors.primary)
                .frame(width: 72, height: 72)
                .background(AppColors.primarySoft)
                .clipShape(Circle())

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}
