import SwiftUI
import UIKit

struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(viewModel: AchievementsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if !viewModel.hasLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorStateView(
                    title: error.title,
                    message: error.message,
                    onRetry: viewModel.load
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content
            }
        }
        .appScreenBackground()
        .navigationTitle("成就")
        .onAppear {
            viewModel.load()
        }
    }

    private var hasAchievements: Bool {
        !viewModel.unlockedWishes.isEmpty
            || !viewModel.completedWishes.isEmpty
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                if hasAchievements {
                    summary
                }

                if !viewModel.completedWishes.isEmpty {
                    wishSection(
                        title: "已兑现",
                        wishes: viewModel.completedWishes
                    )
                }

                if !viewModel.unlockedWishes.isEmpty {
                    wishSection(
                        title: "已解锁",
                        wishes: viewModel.unlockedWishes
                    )
                }

                if !hasAchievements {
                    EmptyStateView(
                        systemImage: "trophy",
                        title: "还没有成就",
                        message: "完成第一个心愿后，你兑现的奖励会收藏在这里。"
                    )
                    .padding(.top, AppSpacing.hero)
                }
            }
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("你为自己完成了这些事")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)

            summaryMetrics
                .appCard()

            Text(
                "累计完成 \(viewModel.completedConditionCount) 项条件 · \(viewModel.totalRecordCount) 条行动记录"
            )
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    @ViewBuilder
    private var summaryMetrics: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                AchievementSummaryMetric(
                    value: viewModel.unlockedWishes.count,
                    title: "已解锁"
                )
                separator
                AchievementSummaryMetric(
                    value: viewModel.completedWishes.count,
                    title: "已兑现"
                )
            }
        } else {
            HStack(spacing: AppSpacing.lg) {
                AchievementSummaryMetric(
                    value: viewModel.unlockedWishes.count,
                    title: "已解锁"
                )
                Rectangle()
                    .fill(AppColors.separator)
                    .frame(width: 0.5, height: 44)
                AchievementSummaryMetric(
                    value: viewModel.completedWishes.count,
                    title: "已兑现"
                )
            }
        }
    }

    private func wishSection(title: String, wishes: [Wish]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, AppSpacing.sm)

            ForEach(Array(wishes.enumerated()), id: \.element.id) { index, wish in
                if index > 0 {
                    separator
                }

                AchievementWishRow(
                    wish: wish,
                    imageData: viewModel.imageData(for: wish),
                    dateText: viewModel.dateText(for: wish)
                )
            }
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(AppColors.separator)
            .frame(height: 0.5)
    }
}

private struct AchievementSummaryMetric: View {
    let value: Int
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("\(value)")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(value) 个\(title)"))
    }
}

private struct AchievementWishRow: View {
    let wish: Wish
    let imageData: Data?
    let dateText: String?

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                    WishThemeDot(theme: theme)

                    Text(wish.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let dateText {
                    Text(dateText)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer(minLength: AppSpacing.sm)
        }
        .padding(.vertical, AppSpacing.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
                .clipShape(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                )
                .accessibilityHidden(true)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(theme.tint)
                Image(systemName: "photo")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(theme.onTint)
            }
            .frame(width: 64, height: 64)
            .accessibilityHidden(true)
        }
    }
}

#Preview("Empty — Light") {
    NavigationStack {
        AchievementsView(
            viewModel: AppContainer.preview().makeAchievementsViewModel()
        )
    }
}

#Preview("Empty — Dark") {
    NavigationStack {
        AchievementsView(
            viewModel: AppContainer.preview().makeAchievementsViewModel()
        )
    }
    .preferredColorScheme(.dark)
}
