import SwiftUI
import UIKit

/// The editorial cover card for the featured wish.
struct FeaturedWishCard: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coverPhoto
            info
        }
        .background(
            theme.container,
            in: RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
        )
        .overlay(alignment: .topTrailing) {
            WishThemeSticker(theme: theme, symbol: "sparkles", size: 38)
                .padding(AppSpacing.lg + AppSpacing.xs)
        }
        .contentShape(
            RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityText))
    }

    private var coverPhoto: some View {
        Color.clear
            .aspectRatio(4.0 / 3.0, contentMode: .fit)
            .overlay {
                WishPhotoView(
                    imageData: imageData,
                    theme: theme,
                    cornerRadius: AppRadius.xl,
                    iconSize: 44
                )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
            )
            .overlay(alignment: .topLeading) {
                StatusBadge(
                    title: wish.status.displayName,
                    tone: wish.status.badgeTone,
                    style: .pill
                )
                .padding(AppSpacing.lg + AppSpacing.xs)
            }
            .padding(10)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .center, spacing: AppSpacing.sm) {
                KickerText(
                    text: "本期心愿",
                    color: theme.onContainer,
                    tracking: 1.0
                )

                Spacer(minLength: AppSpacing.sm)

                if let progressSummary {
                    Text(progressSummary.detailText)
                        .font(AppTypography.footnote.weight(.semibold))
                        .foregroundStyle(theme.onContainer)
                }
            }

            Text(wish.title)
                .font(AppTypography.display)
                .foregroundStyle(theme.onContainer)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            metaLine

            if let progressSummary {
                ProgressIndicator(
                    value: progressSummary.ratio,
                    accessibilityLabel: "条件进度",
                    accessibilityValue: progressSummary.accessibilityValue,
                    style: .hero,
                    isComplete: progressSummary.isComplete,
                    trackColor: theme.onContainer.opacity(0.18)
                )
                .padding(.top, AppSpacing.xxs)
            } else {
                Text("还没有解锁条件")
                    .font(AppTypography.footnote)
                    .foregroundStyle(theme.onContainer)
            }
        }
        .padding(.horizontal, AppSpacing.lg + AppSpacing.xs)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.lg + AppSpacing.xs)
    }

    @ViewBuilder
    private var metaLine: some View {
        let priceText = wish.targetPrice.map {
            $0.formatted(
                .currency(code: wish.currencyCode)
                .locale(Locale(identifier: "zh_CN"))
            )
        }
        let dateText = wish.targetDate.map {
            $0.formatted(
                .dateTime.month().day()
                    .locale(Locale(identifier: "zh_CN"))
            )
        }

        if priceText != nil || dateText != nil {
            HStack(spacing: AppSpacing.sm) {
                if let priceText {
                    Text(priceText)
                }
                if priceText != nil, dateText != nil {
                    Text("·")
                }
                if let dateText {
                    Text("目标 \(dateText)")
                }
            }
            .font(AppTypography.footnote)
            .foregroundStyle(theme.onContainer)
        }
    }

    private var accessibilityText: String {
        var parts = [wish.title, wish.status.displayName]
        if let progressSummary {
            parts.append(progressSummary.accessibilityValue)
        } else {
            parts.append("还没有解锁条件")
        }
        return parts.joined(separator: "，")
    }
}

/// A full-width themed banner used for the next wish below the cover.
struct WishSpotlightCard: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    textContent
                    photo
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                }
            } else {
                HStack(alignment: .center, spacing: AppSpacing.lg) {
                    textContent
                    Spacer(minLength: AppSpacing.sm)
                    photo
                        .frame(width: 100, height: 100)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            theme.container,
            in: RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
        .contentShape(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityText))
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs + 2) {
            ThemeStatusLabel(
                title: wish.status.displayName,
                theme: theme,
                tint: wish.status.indicatorColor
            )

            Text(wish.title)
                .font(AppTypography.editorialHeadline)
                .foregroundStyle(theme.onContainer)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let progressSummary {
                Text(progressSummary.text)
                    .font(AppTypography.footnote)
                    .foregroundStyle(theme.onContainer)
            } else {
                Text("还没有解锁条件")
                    .font(AppTypography.footnote)
                    .foregroundStyle(theme.onContainer)
            }
        }
    }

    private var photo: some View {
        Color.clear
            .overlay {
                WishPhotoView(
                    imageData: imageData,
                    theme: theme,
                    cornerRadius: AppRadius.lg,
                    iconSize: 28
                )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColors.surface.opacity(0.75), lineWidth: 2)
            }
    }

    private var accessibilityText: String {
        var parts = [wish.title, wish.status.displayName]
        parts.append(
            progressSummary?.accessibilityValue ?? "还没有解锁条件"
        )
        return parts.joined(separator: "，")
    }
}

/// A compact themed card used in the two-column wish grid.
struct WishGridCard: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                HStack(spacing: AppSpacing.md) {
                    photo
                        .frame(width: 84, height: 84)
                    textContent
                }
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    photo
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.08, contentMode: .fit)
                    textContent
                }
            }
        }
        .padding(AppSpacing.sm + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            theme.container,
            in: RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
        .contentShape(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityText))
    }

    private var photo: some View {
        Color.clear
            .overlay {
                WishPhotoView(
                    imageData: imageData,
                    theme: theme,
                    cornerRadius: AppRadius.lg,
                    iconSize: 28
                )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
            )
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs + 1) {
            Text(wish.title)
                .font(AppTypography.headline)
                .foregroundStyle(theme.onContainer)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)

            if wish.status == .active {
                if let progressSummary {
                    Text(progressSummary.text)
                        .font(AppTypography.caption.weight(.semibold))
                        .foregroundStyle(theme.onContainer)
                    ProgressIndicator(
                        value: progressSummary.ratio,
                        accessibilityLabel: "条件进度",
                        accessibilityValue: progressSummary.accessibilityValue,
                        style: .inline,
                        isComplete: progressSummary.isComplete,
                        trackColor: theme.onContainer.opacity(0.18)
                    )
                    .accessibilityHidden(true)
                } else {
                    Text("还没有解锁条件")
                        .font(AppTypography.caption)
                        .foregroundStyle(theme.onContainer)
                }
            } else {
                ThemeStatusLabel(
                    title: wish.status.displayName,
                    theme: theme,
                    tint: wish.status.indicatorColor
                )
            }
        }
        .padding(.horizontal, AppSpacing.xxs)
        .padding(.bottom, AppSpacing.xxs)
    }

    private var accessibilityText: String {
        var parts = [wish.title, wish.status.displayName]
        if wish.status == .active {
            parts.append(
                progressSummary?.accessibilityValue ?? "还没有解锁条件"
            )
        }
        return parts.joined(separator: "，")
    }
}

#Preview("Featured — Light") {
    FeaturedWishCardPreview()
        .preferredColorScheme(.light)
}

#Preview("Featured — Dark") {
    FeaturedWishCardPreview()
        .preferredColorScheme(.dark)
}

#Preview("Featured — Long Title") {
    FeaturedWishCardPreview(
        title: "一台可以陪伴很多年、每天阅读都觉得很安静的 Kindle Paperwhite"
    )
    .preferredColorScheme(.light)
}

#Preview("Grid — Light") {
    WishGridPreview()
        .preferredColorScheme(.light)
}

#Preview("Grid — Dark") {
    WishGridPreview()
        .preferredColorScheme(.dark)
}

#Preview("Grid — Accessibility Text") {
    WishGridPreview()
        .environment(\.dynamicTypeSize, .accessibility3)
}

private struct FeaturedWishCardPreview: View {
    var title = "京都的秋天"

    var body: some View {
        Group {
            if let wish = try? Wish(
                title: title,
                targetPrice: 6000,
                targetDate: .now.addingTimeInterval(86_400 * 20),
                createdAt: .now,
                updatedAt: .now
            ) {
                FeaturedWishCard(
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

private struct WishGridPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                if let active = try? Wish(
                    title: "家里的阅读角",
                    createdAt: .now,
                    updatedAt: .now
                ) {
                    WishSpotlightCard(
                        wish: active,
                        progressSummary: WishProgressSummary(
                            completedConditionCount: 1,
                            totalConditionCount: 4
                        )
                    )
                }

                HStack(alignment: .top, spacing: AppSpacing.md) {
                    if let first = try? Wish(
                        title: "学会做提拉米苏",
                        createdAt: .now,
                        updatedAt: .now
                    ) {
                        WishGridCard(
                            wish: first,
                            progressSummary: WishProgressSummary(
                                completedConditionCount: 1,
                                totalConditionCount: 3
                            )
                        )
                    }

                    if let second = try? Wish(
                        title: "周末去露营",
                        createdAt: .now.addingTimeInterval(-60),
                        updatedAt: .now
                    ) {
                        WishGridCard(
                            wish: second,
                            progressSummary: WishProgressSummary(
                                completedConditionCount: 3,
                                totalConditionCount: 3
                            )
                        )
                    }
                }
            }
            .padding(AppSpacing.screenInset)
        }
        .appScreenBackground()
    }
}
