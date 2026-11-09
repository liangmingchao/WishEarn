import SwiftUI
import UIKit

struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel

    init(viewModel: AchievementsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && !viewModel.hasLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorStateView(
                    title: error.title,
                    message: error.message,
                    onRetry: viewModel.load
                )
            } else {
                content
            }
        }
        .appScreenBackground()
        .navigationTitle("成就")
        .task {
            viewModel.load()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppSpacing.md),
                        GridItem(.flexible(), spacing: AppSpacing.md)
                    ],
                    spacing: AppSpacing.md
                ) {
                    AchievementStatCard(
                        title: "已解锁心愿",
                        value: "\(viewModel.unlockedWishes.count)",
                        systemImage: "lock.open",
                        color: AppColors.success
                    )
                    AchievementStatCard(
                        title: "已兑现心愿",
                        value: "\(viewModel.completedWishes.count)",
                        systemImage: "checkmark.seal",
                        color: AppColors.primary
                    )
                    AchievementStatCard(
                        title: "完成条件",
                        value: "\(viewModel.completedConditionCount)",
                        systemImage: "flag.checkered",
                        color: AppColors.warning
                    )
                    AchievementStatCard(
                        title: "行动记录",
                        value: "\(viewModel.totalRecordCount)",
                        systemImage: "chart.bar",
                        color: AppColors.textSecondary
                    )
                }

                if viewModel.unlockedWishes.isEmpty && viewModel.completedWishes.isEmpty {
                    EmptyStateView(
                        systemImage: "trophy",
                        title: "还没有成就",
                        message: "完成第一个心愿后，成就会出现在这里。"
                    )
                    .padding(.top, AppSpacing.xxl)
                } else {
                    if !viewModel.unlockedWishes.isEmpty {
                        wishSection(title: "已解锁", wishes: viewModel.unlockedWishes)
                    }

                    if !viewModel.completedWishes.isEmpty {
                        wishSection(title: "已兑现", wishes: viewModel.completedWishes)
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
    }

    private func wishSection(title: String, wishes: [Wish]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(wishes) { wish in
                AchievementWishRow(
                    wish: wish,
                    imageData: viewModel.imageData(for: wish)
                )
            }
        }
    }
}

private struct AchievementStatCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(color)

            Text(value)
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.textPrimary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

private struct AchievementWishRow: View {
    let wish: Wish
    let imageData: Data?

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(wish.title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(wish.status.displayName)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            StatusBadge(title: wish.status.displayName, tone: wish.status.badgeTone)
        }
        .appCard()
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.primarySoft)
                Image(systemName: "heart.fill")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(AppColors.primary)
            }
            .frame(width: 56, height: 56)
        }
    }
}
