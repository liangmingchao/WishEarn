import SwiftUI

struct TodayView: View {
    @State private var viewModel: TodayViewModel

    init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("今天")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(viewModel.todayText)
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                }

                EmptyStateView(
                    systemImage: "checkmark.circle",
                    title: "今天还没有行动",
                    message: "创建心愿并添加条件后，这里会显示今日待完成的行动。"
                )
                .padding(.top, AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
        }
        .appScreenBackground()
        .navigationTitle("行动")
    }
}

#Preview {
    NavigationStack {
        TodayView(viewModel: TodayViewModel(clock: AppDependencies.preview.clock))
    }
}
