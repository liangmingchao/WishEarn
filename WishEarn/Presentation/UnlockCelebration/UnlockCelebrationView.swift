import SwiftUI
import UIKit

struct UnlockCelebrationView: View {
    let wish: Wish
    let imageData: Data?
    let conditionCount: Int
    let onClaim: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primarySoft, AppColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                imageView
                    .scaleEffect(appeared ? 1 : 0.75)
                    .opacity(appeared ? 1 : 0)

                Text("你做到了")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColors.textPrimary)

                Text(wish.title)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("完成 \(conditionCount) 个条件，奖励已解锁")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                VStack(spacing: AppSpacing.sm) {
                    Button("领取我的奖励", action: onClaim)
                        .buttonStyle(.appPrimary)

                    Button("稍后再说", action: onDismiss)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.xl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
                .shadow(color: AppColors.primary.opacity(0.25), radius: 24, x: 0, y: 12)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColors.surface)
                Image(systemName: "sparkles")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(AppColors.primary)
            }
            .frame(width: 160, height: 160)
            .shadow(color: AppColors.primary.opacity(0.25), radius: 24, x: 0, y: 12)
        }
    }
}
