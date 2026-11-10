import SwiftUI

struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var recordingCondition: Condition?
    @State private var isPresentingWishEditor = false

    private let makeRecordEditorViewModel: (Condition) -> RecordEditorViewModel
    private let makeWishEditorViewModel: () -> WishEditorViewModel

    init(
        viewModel: TodayViewModel,
        makeRecordEditorViewModel: @escaping (Condition) -> RecordEditorViewModel,
        makeWishEditorViewModel: @escaping () -> WishEditorViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeRecordEditorViewModel = makeRecordEditorViewModel
        self.makeWishEditorViewModel = makeWishEditorViewModel
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
        .navigationTitle("今天")
        .sheet(
            item: $recordingCondition,
            onDismiss: {
                viewModel.load()
            }
        ) { condition in
            RecordEditorView(viewModel: makeRecordEditorViewModel(condition))
        }
        .sheet(
            isPresented: $isPresentingWishEditor,
            onDismiss: {
                viewModel.load()
            }
        ) {
            WishEditorView(viewModel: makeWishEditorViewModel())
        }
        .onAppear {
            viewModel.load()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.todayText)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.screenInset)
                    .padding(.top, AppSpacing.xs)

                if viewModel.hasContent {
                    if !viewModel.actionableItems.isEmpty {
                        actionableSection
                    } else {
                        Text("今天暂时没有需要继续记录的行动。")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.horizontal, AppSpacing.screenInset)
                            .padding(.top, AppSpacing.xl)
                    }

                    if !viewModel.recordedTodayItems.isEmpty {
                        readOnlySection(
                            title: "今天已记录",
                            items: viewModel.recordedTodayItems
                        )
                    }

                    if !viewModel.completedItems.isEmpty {
                        readOnlySection(
                            title: "已完成条件",
                            items: viewModel.completedItems
                        )
                    }
                } else {
                    emptyState
                }
            }
            .padding(.bottom, AppSpacing.xl)
        }
    }

    private var actionableSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("今天可以推进这些心愿")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, AppSpacing.sm)
                .padding(.top, AppSpacing.xl)

            ForEach(
                Array(viewModel.actionableItems.enumerated()),
                id: \.element.id
            ) { index, item in
                if index > 0 {
                    separator
                }

                TodayActionRow(item: item) {
                    recordingCondition = item.condition
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private func readOnlySection(
        title: String,
        items: [TodayConditionItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, AppSpacing.sm)
                .padding(.top, AppSpacing.xl)

            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    separator
                }

                TodayReadOnlyRow(item: item)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private var separator: some View {
        Rectangle()
            .fill(AppColors.separator)
            .frame(height: 0.5)
    }

    private var emptyState: some View {
        let createWishAction: (() -> Void)? = viewModel.hasAnyWishes
            ? nil
            : { isPresentingWishEditor = true }

        return EmptyStateView(
            systemImage: "checkmark.circle",
            title: "今天暂时没有需要记录的行动",
            message: "继续按自己的节奏前进。新的行动会在这里出现。",
            actionTitle: viewModel.hasAnyWishes ? nil : "创建第一个心愿",
            action: createWishAction
        )
        .padding(.top, AppSpacing.hero)
    }
}

private struct TodayActionRow: View {
    let item: TodayConditionItem
    let onRecord: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    content
                    recordButton
                }
            } else {
                HStack(alignment: .center, spacing: AppSpacing.md) {
                    content
                    Spacer(minLength: AppSpacing.sm)
                    recordButton
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
        .frame(minHeight: 84, alignment: .leading)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                WishThemeDot(theme: .forWish(item.wish))

                Text(item.wish.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Text(item.condition.title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.progressText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)

            if let todayRecordText = item.todayRecordText {
                Text(todayRecordText)
                    .font(AppTypography.caption2)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.accessibilityDescription))
    }

    private var recordButton: some View {
        Button(action: onRecord) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "plus")
                Text("记录")
            }
            .font(AppTypography.footnote.weight(.semibold))
            .foregroundStyle(AppColors.accent)
            .padding(.horizontal, AppSpacing.md)
            .frame(minHeight: AppLayout.touchTarget)
            .background(AppColors.accentSoft, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("记录\(item.condition.title)")
        .accessibilityHint("打开行动记录编辑器")
    }
}

private struct TodayReadOnlyRow: View {
    let item: TodayConditionItem

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        checkmark
                        content
                    }
                    stateLabel
                        .padding(.leading, 28)
                }
            } else {
                HStack(alignment: .center, spacing: AppSpacing.md) {
                    checkmark
                    content
                    Spacer(minLength: AppSpacing.sm)
                    stateLabel
                }
            }
        }
        .padding(.vertical, AppSpacing.md)
        .frame(minHeight: 72, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.accessibilityDescription))
    }

    private var checkmark: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(AppColors.success)
            .frame(width: 20, height: 20)
            .accessibilityHidden(true)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                WishThemeDot(theme: .forWish(item.wish))

                Text(item.wish.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Text(item.condition.title)
                .font(AppTypography.callout.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.progressText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var stateLabel: some View {
        Text(item.stateText)
            .font(AppTypography.caption.weight(.semibold))
            .foregroundStyle(AppColors.textSecondary)
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        TodayView(
            viewModel: container.makeTodayViewModel(),
            makeRecordEditorViewModel: { condition in
                container.makeRecordEditorViewModel(condition: condition, record: nil)
            },
            makeWishEditorViewModel: {
                container.makeWishEditorViewModel()
            }
        )
    }
}
