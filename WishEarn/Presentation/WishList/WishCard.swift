import SwiftUI
import UIKit

struct WishCard: View {
    let wish: Wish
    let conditionCount: Int
    var imageData: Data? = nil
    var overallProgress: Double? = nil

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                    Text(wish.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)

                    Spacer(minLength: AppSpacing.sm)

                    StatusBadge(title: wish.status.displayName, tone: wish.status.badgeTone)
                }

                if let price = wish.targetPrice {
                    Text(price.formatted(.currency(code: wish.currencyCode).locale(Locale(identifier: "zh_CN"))))
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Text("\(conditionCount) 个条件")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                if let overallProgress {
                    HStack {
                        Text("总体进度")
                            .font(AppTypography.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text("\(Int(overallProgress * 100))%")
                            .font(AppTypography.caption2)
                            .foregroundStyle(AppColors.primary)
                    }
                    ProgressView(value: overallProgress)
                        .tint(overallProgress >= 1 ? AppColors.success : AppColors.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.primarySoft)

                Image(systemName: "heart.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(AppColors.primary)
            }
            .frame(width: 64, height: 64)
        }
    }
}

#Preview {
    Group {
        if let wish = try? Wish(
            title: "Kindle Paperwhite",
            targetPrice: 1099,
            createdAt: .now,
            updatedAt: .now
        ) {
            WishCard(wish: wish, conditionCount: 3)
        } else {
            Text("Preview data unavailable")
        }
    }
    .padding()
    .appScreenBackground()
}
