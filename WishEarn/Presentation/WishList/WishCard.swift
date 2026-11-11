import SwiftUI
import UIKit

struct WishCard: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            WishThemeMark(theme: theme)
            FeaturedWishImage(imageData: imageData, theme: theme)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(wish.title)
                    .font(AppTypography.display)
                    .tracking(-1)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let price = wish.targetPrice {
                    Text(
                        price.formatted(
                            .currency(code: wish.currencyCode)
                            .locale(Locale(identifier: "zh_CN"))
                        )
                    )
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                }

                if let progressSummary {
                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                        Text(progressSummary.text)
                            .font(AppTypography.callout.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .accessibilityHidden(true)

                        Spacer(minLength: AppSpacing.sm)

                        if !progressSummary.isComplete {
                            Text("还差 \(progressSummary.totalConditionCount - progressSummary.completedConditionCount) 项")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }

                    if progressSummary.totalConditionCount <= 8 {
                        SegmentedProgress(
                            completed: progressSummary.completedConditionCount,
                            total: progressSummary.totalConditionCount
                        )
                    } else {
                        ProgressIndicator(
                            value: progressSummary.ratio,
                            accessibilityLabel: "条件进度",
                            accessibilityValue: progressSummary.accessibilityValue,
                            style: .hero,
                            isComplete: progressSummary.isComplete
                        )
                    }
                } else {
                    Text("还没有解锁条件")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct WishRow: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    thumbnail
                    textContent
                }
            } else {
                HStack(spacing: AppSpacing.md) {
                    thumbnail
                    textContent
                    Spacer(minLength: AppSpacing.sm)
                    Image(systemName: "chevron.right")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                WishThemeDot(theme: .forWish(wish))

                Text(wish.title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if wish.status == .active {
                if let progressSummary {
                    Text(progressSummary.text)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    Text("还没有解锁条件")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                StatusBadge(
                    title: wish.status.displayName,
                    tone: wish.status.badgeTone
                )
            }
        }
    }

    private var thumbnail: some View {
        WishThumbnail(imageData: imageData, theme: .forWish(wish))
    }
}

private struct FeaturedWishImage: View {
    let imageData: Data?
    let theme: WishTheme

    var body: some View {
        // Color.clear establishes the crop before the image is overlaid; using
        // the image itself as the aspect-ratio source lets a portrait source
        // drive the card height. The home lead image is deliberately shallower
        // than the Detail hero so it does not overpower the title below it.
        Color.clear
            .aspectRatio(2.0, contentMode: .fit)
            .overlay {
                ZStack {
                    WishImagePlaceholder(
                        iconSize: 38,
                        background: theme.softTint,
                        foreground: theme.onSoftTint
                    )

                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

private struct WishThumbnail: View {
    let imageData: Data?
    let theme: WishTheme

    var body: some View {
        ZStack {
            WishImagePlaceholder(
                iconSize: 24,
                background: theme.tint,
                foreground: theme.onTint
            )

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
        )
        .accessibilityHidden(true)
    }
}

private struct WishImagePlaceholder: View {
    let iconSize: CGFloat
    let background: Color
    let foreground: Color

    var body: some View {
        ZStack {
            background

            Image(systemName: "photo")
                .font(.system(size: iconSize, weight: .light))
                .foregroundStyle(foreground)
        }
    }
}

#Preview("Featured — Light") {
    WishCardPreview()
        .preferredColorScheme(.light)
}

#Preview("Featured — Dark") {
    WishCardPreview()
        .preferredColorScheme(.dark)
}

#Preview("Featured — Long Title") {
    WishCardPreview(
        title: "一台可以陪伴很多年、每天阅读都觉得很安静的 Kindle Paperwhite"
    )
    .preferredColorScheme(.light)
}

#Preview("Row — Light") {
    WishRowPreview()
        .preferredColorScheme(.light)
}

#Preview("Row — Dark") {
    WishRowPreview()
        .preferredColorScheme(.dark)
}

private struct WishCardPreview: View {
    var title = "Kindle Paperwhite"

    var body: some View {
        Group {
            if let wish = try? Wish(
                title: title,
                targetPrice: 1099,
                createdAt: .now,
                updatedAt: .now
            ) {
                WishCard(
                    wish: wish,
                    progressSummary: WishProgressSummary(
                        completedConditionCount: 2,
                        totalConditionCount: 3
                    )
                )
            } else {
                Text("Preview data unavailable")
            }
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}

private struct WishRowPreview: View {
    var body: some View {
        VStack(spacing: 0) {
            if let active = try? Wish(
                title: "周末去京都",
                createdAt: .now,
                updatedAt: .now
            ) {
                WishRow(
                    wish: active,
                    progressSummary: WishProgressSummary(
                        completedConditionCount: 1,
                        totalConditionCount: 4
                    )
                )

                Rectangle()
                    .fill(AppColors.separator)
                    .frame(height: 0.5)
            }

            if let paused = try? Wish(
                title: "新相机",
                status: .paused,
                createdAt: .now.addingTimeInterval(-60),
                updatedAt: .now
            ) {
                WishRow(wish: paused, progressSummary: nil)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
