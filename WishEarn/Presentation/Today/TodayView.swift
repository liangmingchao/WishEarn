import SwiftUI

struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var recordingCondition: Condition?

    private let makeRecordEditorViewModel: (Condition) -> RecordEditorViewModel

    init(
        viewModel: TodayViewModel,
        makeRecordEditorViewModel: @escaping (Condition) -> RecordEditorViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeRecordEditorViewModel = makeRecordEditorViewModel
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
            } else if viewModel.items.isEmpty {
                emptyContent
            } else {
                listContent
            }
        }
        .appScreenBackground()
        .navigationTitle("行动")
        .sheet(
            item: $recordingCondition,
            onDismiss: {
                viewModel.load()
            }
        ) { condition in
            RecordEditorView(viewModel: makeRecordEditorViewModel(condition))
        }
        .task {
            viewModel.load()
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            header

            EmptyStateView(
                systemImage: "checkmark.circle",
                title: "今天还没有行动",
                message: "创建心愿并添加条件后，这里会显示今日待完成的行动。"
            )
            .padding(.top, AppSpacing.xxl)

            Spacer()
        }
        .padding(AppSpacing.lg)
    }

    private var listContent: some View {
        List {
            Section {
                header
                    .listRowInsets(EdgeInsets(top: AppSpacing.md, leading: AppSpacing.lg, bottom: AppSpacing.sm, trailing: AppSpacing.lg))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section("今日行动") {
                ForEach(viewModel.items) { item in
                    Button {
                        if item.canRecord {
                            recordingCondition = item.condition
                        }
                    } label: {
                        TodayConditionRow(item: item)
                    }
                    .buttonStyle(.plain)
                    .disabled(!item.canRecord)
                    .listRowBackground(AppColors.surface)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appScreenBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("今天")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            Text(viewModel.todayText)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

private struct TodayConditionRow: View {
    let item: TodayConditionItem

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(item.wish.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: AppSpacing.sm) {
                    Text(item.condition.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    if item.condition.isRequired {
                        StatusBadge(title: "必需", tone: .primary)
                    }
                }

                Text("\(item.condition.type.displayName) · \(item.condition.targetDescription)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Text(item.summaryText)
                    .font(AppTypography.caption2)
                    .foregroundStyle(item.isDone ? AppColors.success : AppColors.primary)
            }

            Spacer()

            Image(systemName: item.canRecord ? "plus.circle.fill" : "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(item.isDone ? AppColors.success : AppColors.primary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        TodayView(
            viewModel: container.makeTodayViewModel(),
            makeRecordEditorViewModel: { condition in
                container.makeRecordEditorViewModel(condition: condition, record: nil)
            }
        )
    }
}
