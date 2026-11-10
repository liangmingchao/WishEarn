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
        // The editorial headline is the page title; a navigation title would
        // duplicate it.
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
                    if let hero = viewModel.heroItem {
                        heroSection(hero)
                    }

                    if !viewModel.remainingActionableItems.isEmpty {
                        section(
                            title: "还可以推进",
                            items: viewModel.remainingActionableItems
                        )
                    }

                    if !viewModel.recordedTodayItems.isEmpty {
                        section(
                            title: "今天已记录",
                            items: viewModel.recordedTodayItems
                        )
                    }

                    if !viewModel.completedItems.isEmpty {
                        section(
                            title: "已完成",
                            items: viewModel.completedItems
                        )
                    }
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.bottom, AppSpacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.todayText)
                .font(AppTypography.kicker)
                .tracking(1.1)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, AppSpacing.sm)

            Text("小步走，\n也会到。")
                .font(AppTypography.display)
                .tracking(-1.4)
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1)
                .padding(.top, AppSpacing.md)
                .accessibilityLabel("小步走，也会到")

            StatusChip(
                value: "\(viewModel.actionableItems.count)",
                unit: "件小事",
                caption: chipCaption
            )
            .padding(.top, AppSpacing.xl)
        }
    }

    private var chipCaption: String {
        if !viewModel.actionableItems.isEmpty {
            return "今天可以推进"
        }
        if !viewModel.recordedTodayItems.isEmpty {
            return "今天已经完成"
        }
        return "今天没有待办"
    }

    // MARK: - Hero

    private func heroSection(_ item: TodayConditionItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageData = viewModel.heroImageData {
                WishHeroPhoto(
                    imageData: imageData,
                    theme: .forWish(item.wish)
                )
                .padding(.top, AppSpacing.xl)
            } else {
                WishThemeMark(theme: .forWish(item.wish), width: 30)
                    .padding(.top, AppSpacing.xl)
            }

            Text("继续这个心愿")
                .font(AppTypography.kicker)
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, AppSpacing.md)

            Text(item.wish.title)
                .font(AppTypography.title)
                .tracking(-0.6)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AppSpacing.xs)

            Text("\(item.condition.title) · \(item.progressText)")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AppSpacing.sm)

            ProgressIndicator(
                value: item.snapshot.progressRatio,
                accessibilityLabel: "条件进度",
                accessibilityValue: item.progressText,
                style: .hero,
                isComplete: item.snapshot.isCompleted
            )
            .padding(.top, AppSpacing.lg)

            Button("记录\(item.condition.title)") {
                recordingCondition = item.condition
            }
            .buttonStyle(.appPrimary)
            .padding(.top, AppSpacing.xl)
            .accessibilityIdentifier("today-hero-record")
        }
    }

    // MARK: - Rows

    private func section(
        title: String,
        items: [TodayConditionItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTypography.kicker)
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.top, AppSpacing.xxl)
                .padding(.bottom, AppSpacing.xs)

            HairlineDivider()

            ForEach(items) { item in
                if item.state == .actionable {
                    actionableRow(item)
                } else {
                    readOnlyRow(item)
                }

                HairlineDivider()
            }
        }
    }

    private func actionableRow(_ item: TodayConditionItem) -> some View {
        Button {
            recordingCondition = item.condition
        } label: {
            HStack(spacing: AppSpacing.md) {
                WishThemeDot(theme: .forWish(item.wish), size: 8)

                VStack(alignment: .leading, spacing: Spacing.rowGap) {
                    Text(item.condition.title)
                        .font(AppTypography.callout.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(item.wish.title) · \(item.progressText)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: AppSpacing.sm)

                Text("记录")
                    .font(AppTypography.caption.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .overlay(
                        Capsule().stroke(AppColors.separator, lineWidth: 1)
                    )
            }
            .padding(.vertical, AppSpacing.md + 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.accessibilityDescription))
        .accessibilityHint(Text("打开行动记录编辑器"))
    }

    private func readOnlyRow(_ item: TodayConditionItem) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: item.state == .completed
                ? "checkmark.circle.fill"
                : "clock")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(
                    item.state == .completed
                        ? AppColors.success
                        : AppColors.textTertiary
                )
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.rowGap) {
                Text(item.condition.title)
                    .font(AppTypography.callout.weight(.medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(item.wish.title) · \(item.progressText)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: AppSpacing.sm)

            Text(item.stateText)
                .font(AppTypography.caption.weight(.medium))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.vertical, AppSpacing.md + 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(item.accessibilityDescription))
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

    private enum Spacing {
        static let rowGap: CGFloat = 3
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
