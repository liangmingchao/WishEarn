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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                header

                if viewModel.hasContent {
                    encouragementCard

                    if !viewModel.actionableItems.isEmpty {
                        actionableSection
                    }

                    if !viewModel.recordedTodayItems.isEmpty {
                        doneSection(
                            title: "今天已记录",
                            items: viewModel.recordedTodayItems
                        )
                    }

                    if !viewModel.completedItems.isEmpty {
                        doneSection(
                            title: "已完成条件",
                            items: viewModel.completedItems
                        )
                    }
                } else {
                    emptyState
                }
            }
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            KickerText(
                text: viewModel.todayText,
                color: AppColors.primary,
                tracking: 0.6
            )

            Text("今天，慢慢来")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)

            Text("每一个小行动，都在把心愿拉近一点。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xs)
    }

    private var encouragementCard: some View {
        let count = viewModel.actionableItems.count
        let title = count > 0
            ? "按自己的节奏，走一小步"
            : "今天的行动，已经完成了"
        let message = count > 0
            ? "今天有 \(count) 个小行动，可以推进你的心愿。"
            : "给自己一点掌声，明天再继续。"

        let cardShape = RoundedRectangle(
            cornerRadius: AppRadius.xl,
            style: .continuous
        )

        return HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(AppColors.clay)
                .frame(width: 4)
                .padding(.vertical, AppSpacing.lg)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs + 2) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.clayText)
                        .accessibilityHidden(true)

                    KickerText(
                        text: "今日心情",
                        color: AppColors.clayText,
                        tracking: 0.8
                    )
                }

                Text(title)
                    .font(AppTypography.editorialTitle)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(message)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .accessibilityElement(children: .combine)
        }
        .background(AppColors.surface, in: cardShape)
        .overlay {
            cardShape.stroke(AppColors.separator, lineWidth: 0.8)
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xl)
    }

    private var actionableSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            EditorialSectionHeader(
                title: "今天可以推进",
                detail: "\(viewModel.actionableItems.count)"
            )

            ForEach(viewModel.actionableItems) { item in
                TodayActionCard(item: item) {
                    recordingCondition = item.condition
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xl)
    }

    private func doneSection(
        title: String,
        items: [TodayConditionItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            EditorialSectionHeader(
                title: title,
                detail: "\(items.count)",
                showsSparkle: false
            )

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Rectangle()
                            .fill(AppColors.separator)
                            .frame(height: 0.5)
                            .padding(.leading, 46)
                    }

                    TodayDoneRow(item: item)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xs)
            .background(
                AppColors.surface,
                in: RoundedRectangle(
                    cornerRadius: AppRadius.card,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.card,
                    style: .continuous
                )
                .stroke(AppColors.separator, lineWidth: 0.8)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xl)
    }

    private var emptyState: some View {
        let createWishAction: (() -> Void)? = viewModel.hasAnyWishes
            ? nil
            : { isPresentingWishEditor = true }

        return EmptyStateView(
            systemImage: "sun.max",
            title: "今天没有需要赶的路",
            message: "新的行动会在合适的时候出现。也可以先为自己许下一个心愿。",
            actionTitle: viewModel.hasAnyWishes ? nil : "创建第一个心愿",
            action: createWishAction
        )
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xl)
    }
}

private struct TodayActionCard: View {
    let item: TodayConditionItem
    let onRecord: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var theme: WishTheme {
        .forWish(item.wish)
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    content
                    recordButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                HStack(alignment: .center, spacing: AppSpacing.md) {
                    content
                    Spacer(minLength: AppSpacing.sm)
                    recordButton
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.separator, lineWidth: 0.8)
        }
    }

    private var content: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            iconPlate

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    WishThemeDot(theme: theme)

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
    }

    private var iconPlate: some View {
        Image(systemName: item.condition.type.symbolName)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(theme.onTint)
            .frame(width: 42, height: 42)
            .background(
                theme.tint,
                in: RoundedRectangle(
                    cornerRadius: AppRadius.md,
                    style: .continuous
                )
            )
            .accessibilityHidden(true)
    }

    private var recordButton: some View {
        Button(action: onRecord) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))

                Text("记录")
                    .font(AppTypography.footnote.weight(.semibold))
            }
            .foregroundStyle(AppColors.primary)
            .padding(.horizontal, AppSpacing.md)
            .frame(minHeight: AppLayout.touchTarget)
            .background(AppColors.primarySoft, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.pressableChip)
        .accessibilityLabel("记录\(item.condition.title)")
        .accessibilityHint("打开行动记录编辑器")
    }
}

private struct TodayDoneRow: View {
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
                        .padding(.leading, 46)
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
        .padding(.vertical, AppSpacing.sm)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.accessibilityDescription))
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(AppColors.successSoft)

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.success)
        }
        .frame(width: 34, height: 34)
        .accessibilityHidden(true)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(item.wish.title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)

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
