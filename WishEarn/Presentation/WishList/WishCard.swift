import SwiftUI
import UIKit

/// The lead card on the home screen: one wish, its photograph, and how close
/// it is to unlocking. Copy stays minimal so the image can carry the emotion.
struct WishCard: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil
    /// Small tag pinned to the cover. Pass nil to hide it.
    var badge: String? = "离解锁最近"

    private var theme: WishTheme {
        .forWish(wish)
    }

    private var ratio: Double {
        progressSummary?.ratio ?? 0
    }

    var body: some View {
        Color.clear
            .aspectRatio(AppLayout.featuredAspectRatio, contentMode: .fit)
            .overlay {
                cardLayers
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
            )
            .appPaperShadow()
            .contentShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(accessibilityText))
            .accessibilityAddTraits(.isButton)
    }

    private var cardLayers: some View {
        ZStack(alignment: .bottomLeading) {
            WishCoverArtwork(
                wish: wish,
                theme: theme,
                imageData: imageData,
                monogramScale: 1.2
            )

            // Photograph legibility scrim. Kept inside the card so the paper
            // canvas stays clean around it.
            LinearGradient(
                stops: [
                    .init(color: AppColors.imageScrim.opacity(0.0), location: 0.32),
                    .init(color: AppColors.imageScrim.opacity(0.52), location: 0.72),
                    .init(color: AppColors.imageScrim.opacity(0.82), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(wish.title)
                    .font(AppTypography.wishTitle)
                    .foregroundStyle(AppColors.onImage)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let progressSummary {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(progressSummary.completedConditionCount) / \(progressSummary.totalConditionCount) 条件完成")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.onImage.opacity(0.86))

                        Spacer(minLength: AppSpacing.sm)

                        Text("\(Int((ratio * 100).rounded()))%")
                            .font(AppTypography.number)
                            .foregroundStyle(AppColors.onImage)
                            .monospacedDigit()
                    }

                    CoverProgressBar(value: ratio)
                } else {
                    Text("还没有解锁条件")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.onImage.opacity(0.86))
                }
            }
            .padding(AppSpacing.lg + 2)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let badge {
                CoverBadge(text: badge)
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var accessibilityText: String {
        var parts = [wish.title]
        if let progressSummary {
            parts.append(progressSummary.accessibilityValue)
        } else {
            parts.append("还没有解锁条件")
        }
        return parts.joined(separator: "，")
    }
}

/// A compact, scannable wish row: thumbnail, name, and a single progress line.
struct WishRow: View {
    let wish: Wish
    let progressSummary: WishProgressSummary?
    var imageData: Data? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md + 2) {
            WishThumbnail(wish: wish, imageData: imageData, theme: theme)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                    Text(wish.title)
                        .font(AppTypography.wishTitleCompact)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)

                    if wish.status == .unlocked {
                        MiniStatusTag(text: "已解锁", tone: .reward)
                    } else if wish.status == .completed {
                        MiniStatusTag(text: "已兑现", tone: .done)
                    }
                }

                Text(metaText)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(2)

                if wish.status == .active, let progressSummary {
                    ProgressIndicator(
                        value: progressSummary.ratio,
                        accessibilityLabel: "条件进度",
                        accessibilityValue: progressSummary.accessibilityValue,
                        style: .inline,
                        isComplete: progressSummary.isComplete
                    )
                    .padding(.top, 2)
                }
            }

            Spacer(minLength: AppSpacing.xs)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary.opacity(0.7))
                .accessibilityHidden(true)
        }
        .padding(.vertical, AppSpacing.md + 2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityText))
        .accessibilityAddTraits(.isButton)
    }

    private var metaText: String {
        switch wish.status {
        case .unlocked:
            return "已达成 · 等待领取"
        case .completed:
            return "已兑现 · 这份奖励是你换来的"
        case .paused:
            return "已暂停 · 随时可以继续"
        case .archived:
            return "已归档"
        case .active:
            guard let progressSummary else { return "还没有解锁条件" }
            let remaining = progressSummary.totalConditionCount
                - progressSummary.completedConditionCount
            let percent = Int((progressSummary.ratio * 100).rounded())
            return remaining > 0
                ? "\(percent)% · 还差 \(remaining) 项"
                : "\(percent)% · 已达成"
        }
    }

    private var accessibilityText: String {
        "\(wish.title)，\(metaText)"
    }
}

/// Cover artwork shared by the home card and the detail hero.
struct WishCoverArtwork: View {
    let wish: Wish
    let theme: WishTheme
    let imageData: Data?
    var monogramScale: CGFloat = 1

    var body: some View {
        Color.clear
            .overlay {
                ZStack {
                    WishMonogramPlate(
                        wish: wish,
                        theme: theme,
                        scale: monogramScale
                    )

                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

struct CoverProgressBar: View {
    let value: Double
    var tint: Color = AppColors.onImage

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.opacity(0.28))

                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }
}

struct CoverBadge: View {
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(
            AppColors.canvas.opacity(0.92),
            in: Capsule()
        )
        .accessibilityHidden(true)
    }
}

struct MiniStatusTag: View {
    enum Tone {
        case reward
        case done
    }

    let text: String
    let tone: Tone

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(tone == .reward ? AppColors.coralText : AppColors.primary)
            .padding(.horizontal, 6)
            .frame(height: 17)
            .background(
                tone == .reward ? AppColors.coralSoft : AppColors.primarySoft,
                in: RoundedRectangle(cornerRadius: 5, style: .continuous)
            )
            .fixedSize()
            .accessibilityHidden(true)
    }
}

private struct WishThumbnail: View {
    let wish: Wish
    let imageData: Data?
    let theme: WishTheme

    var body: some View {
        ZStack {
            WishMonogramPlate(wish: wish, theme: theme, scale: 0.62)

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(
            width: AppLayout.thumbnailSize,
            height: AppLayout.thumbnailSize
        )
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.thumbnail, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.thumbnail, style: .continuous)
                .stroke(AppColors.separatorSoft, lineWidth: 0.5)
        )
        .accessibilityHidden(true)
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
                    .fill(AppColors.separatorSoft)
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
