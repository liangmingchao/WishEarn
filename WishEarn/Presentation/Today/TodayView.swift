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
        .toolbar(.hidden, for: .navigationBar)
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
                    summaryCard
                        .padding(.horizontal, AppSpacing.screenInset)
                        .padding(.top, AppSpacing.lg)

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
            .padding(.bottom, AppSpacing.xxl)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(viewModel.todayText)
                .font(AppTypography.eyebrow)
                .tracking(1.2)
                .foregroundStyle(AppColors.textTertiary)

            Text("今天")
                .font(AppTypography.pageTitle)
                .foregroundStyle(AppColors.textPrimary)

            Text(pendingDescription)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.top, 1)
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.md)
    }

    private var summaryCard: some View {
        HStack(spacing: AppSpacing.lg) {
            TodayProgressRing(
                completed: doneCount,
                total: totalCount
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(doneCount == totalCount ? "今天的行动都记录好了" : "先完成一项，再想别的")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(viewModel.actionableItems.count) 项待记录 · \(doneCount) 项已完成")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.elevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.separatorSoft, lineWidth: 1)
        )
    }

    private var actionableSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("今天可以推进", trailing: "\(viewModel.actionableItems.count) 项")
                .padding(.top, AppSpacing.section)

            ForEach(Array(viewModel.actionableItems.enumerated()), id: \.element.id) { index, item in
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
            sectionHeader(title, trailing: nil)
                .padding(.top, AppSpacing.section)

            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    separator
                }

                TodayReadOnlyRow(item: item)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private func sectionHeader(_ title: String, trailing: String?) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(.bottom, AppSpacing.xs)
    }

    private var separator: some View {
        Rectangle()
            .fill(AppColors.separatorSoft)
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

    // MARK: - Derived data

    private var totalCount: Int {
        viewModel.actionableItems.count
            + viewModel.recordedTodayItems.count
            + viewModel.completedItems.count
    }

    private var doneCount: Int {
        viewModel.recordedTodayItems.count + viewModel.completedItems.count
    }

    private var pendingDescription: String {
        if viewModel.actionableItems.isEmpty {
            return viewModel.hasContent ? "今天要做的事都完成了" : "今天还没有需要记录的行动"
        }
        return "\(viewModel.actionableItems.count) 项待记录，挑一件先做"
    }
}

// MARK: - Rows

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
        .padding(.vertical, AppSpacing.md + 2)
        .frame(minHeight: 76, alignment: .leading)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.condition.title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                WishThemeDot(theme: .forWish(item.wish), size: 6)

                Text(item.wish.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Text(item.progressText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(2)

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
            Text("记录")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.onPrimary)
                .padding(.horizontal, 15)
                .frame(height: 34)
                .background(AppColors.primary, in: Capsule())
                .frame(minWidth: AppLayout.touchTarget, minHeight: AppLayout.touchTarget)
                .contentShape(Rectangle())
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
                        .padding(.leading, 26)
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
        .padding(.vertical, AppSpacing.md + 2)
        .frame(minHeight: 68, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.accessibilityDescription))
    }

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(AppColors.primary)
            .frame(width: 20, height: 20)
            .background(AppColors.primarySoft, in: Circle())
            .accessibilityHidden(true)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.condition.title)
                .font(AppTypography.callout.weight(.medium))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                WishThemeDot(theme: .forWish(item.wish), size: 6)

                Text(item.wish.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Text(item.progressText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var stateLabel: some View {
        Text(item.stateText)
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.textTertiary)
            .fixedSize()
    }
}

// MARK: - Ring

private struct TodayProgressRing: View {
    let completed: Int
    let total: Int

    private var ratio: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.progressTrack, lineWidth: 5)

            Circle()
                .trim(from: 0, to: min(max(ratio, 0), 1))
                .stroke(
                    AppColors.primary,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: -1) {
                Text("\(completed)")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.textPrimary)

                Text("/ \(total)")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .frame(width: 66, height: 66)
        .animation(AppMotion.standard, value: ratio)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("今日进度")
        .accessibilityValue("已完成 \(completed) 项，共 \(total) 项")
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
