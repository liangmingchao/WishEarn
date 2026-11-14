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
        .toolbar(.hidden, for: .navigationBar)
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
            VStack(alignment: .leading, spacing: 0) {
                header

                if hasAchievements {
                    statsCard
                        .padding(.horizontal, AppSpacing.screenInset)
                        .padding(.top, AppSpacing.lg)

                    if !viewModel.completedWishes.isEmpty {
                        wishSection(
                            title: "已兑现",
                            wishes: viewModel.completedWishes
                        )
                    }

                    if !viewModel.unlockedWishes.isEmpty {
                        wishSection(
                            title: "已解锁 · 等待领取",
                            wishes: viewModel.unlockedWishes
                        )
                    }

                    Text(
                        "累计完成 \(viewModel.completedConditionCount) 项条件 · \(viewModel.totalRecordCount) 条行动记录"
                    )
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
                    .padding(.horizontal, AppSpacing.screenInset)
                    .padding(.top, AppSpacing.section)
                } else {
                    EmptyStateView(
                        systemImage: "trophy",
                        title: "还没有成就",
                        message: "完成第一个心愿后，你兑现的奖励会收藏在这里。"
                    )
                    .padding(.top, AppSpacing.hero)
                }
            }
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xxl)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CHRONICLE")
                .font(AppTypography.eyebrow)
                .tracking(1.4)
                .foregroundStyle(AppColors.textTertiary)

            Text("成就")
                .font(AppTypography.pageTitle)
                .foregroundStyle(AppColors.textPrimary)

            Text(
                viewModel.completedWishes.isEmpty
                    ? "这里会收下你为自己兑现的奖励"
                    : "你已经把 \(viewModel.completedWishes.count) 个心愿变成了现实"
            )
            .font(AppTypography.callout)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.top, 1)
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private var statsCard: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    metric(value: viewModel.completedWishes.count, title: "兑现奖励")
                    separator
                    metric(value: viewModel.unlockedWishes.count, title: "解锁心愿")
                    separator
                    metric(value: viewModel.completedConditionCount, title: "完成条件")
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    metric(value: viewModel.completedWishes.count, title: "兑现奖励")
                    verticalSeparator
                    metric(value: viewModel.unlockedWishes.count, title: "解锁心愿")
                    verticalSeparator
                    metric(value: viewModel.completedConditionCount, title: "完成条件")
                }
            }
        }
        .padding(.vertical, AppSpacing.lg)
        .padding(.horizontal, AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.elevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.separatorSoft, lineWidth: 1)
        )
    }

    private func metric(value: Int, title: String) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(AppColors.textPrimary)

            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(value) 个\(title)"))
    }

    private var verticalSeparator: some View {
        Rectangle()
            .fill(AppColors.separatorSoft)
            .frame(width: 0.5, height: 34)
            .padding(.top, AppSpacing.xs)
    }

    private func wishSection(title: String, wishes: [Wish]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("\(wishes.count) 个")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.bottom, AppSpacing.xs)

            ForEach(Array(wishes.enumerated()), id: \.element.id) { index, wish in
                if index > 0 {
                    Rectangle()
                        .fill(AppColors.separatorSoft)
                        .frame(height: 0.5)
                        .padding(.leading, AppLayout.thumbnailSize + AppSpacing.md + 2)
                }

                AchievementWishRow(
                    wish: wish,
                    imageData: viewModel.imageData(for: wish),
                    dateText: viewModel.dateText(for: wish)
                )
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.section)
    }

    private var separator: some View {
        Rectangle()
            .fill(AppColors.separatorSoft)
            .frame(height: 0.5)
    }
}

private struct AchievementWishRow: View {
    let wish: Wish
    let imageData: Data?
    let dateText: String?

    private var theme: WishTheme {
        .forWish(wish)
    }

    private var isCompleted: Bool {
        wish.status == .completed
    }

    var body: some View {
        HStack(spacing: AppSpacing.md + 2) {
            thumbnail

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                    Text(wish.title)
                        .font(AppTypography.wishTitleCompact)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    MiniStatusTag(
                        text: isCompleted ? "已兑现" : "已解锁",
                        tone: isCompleted ? .done : .reward
                    )
                }

                if let dateText {
                    Text(dateText)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Spacer(minLength: AppSpacing.sm)
        }
        .padding(.vertical, AppSpacing.md + 2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var thumbnail: some View {
        ZStack {
            WishMonogramPlate(wish: wish, theme: theme, scale: 0.62)

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: AppLayout.thumbnailSize, height: AppLayout.thumbnailSize)
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
