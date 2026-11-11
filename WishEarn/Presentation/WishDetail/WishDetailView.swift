import SwiftUI
import UIKit

struct WishDetailView: View {
    @Environment(UnlockCoordinator.self) private var unlockCoordinator
    @State private var viewModel: WishDetailViewModel
    @State private var listEditMode: EditMode = .inactive
    @State private var isPresentingNewCondition = false
    @State private var isPresentingWishEditor = false
    @State private var editingCondition: Condition?
    @State private var conditionPendingDeletion: Condition?
    @State private var selectedCondition: Condition?
    @State private var isShowingConditionDetail = false
    @State private var recordCondition: Condition?

    private let makeWishEditorViewModel: (Wish) -> WishEditorViewModel
    private let makeConditionEditorViewModel: (Condition?, Int) -> ConditionEditorViewModel
    private let makeConditionDetailViewModel: (Condition) -> ConditionDetailViewModel
    private let makeRecordEditorViewModel: (Condition, ProgressRecord?) -> RecordEditorViewModel

    init(
        viewModel: WishDetailViewModel,
        makeWishEditorViewModel: @escaping (Wish) -> WishEditorViewModel,
        makeConditionEditorViewModel: @escaping (Condition?, Int) -> ConditionEditorViewModel,
        makeConditionDetailViewModel: @escaping (Condition) -> ConditionDetailViewModel,
        makeRecordEditorViewModel: @escaping (Condition, ProgressRecord?) -> RecordEditorViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeWishEditorViewModel = makeWishEditorViewModel
        self.makeConditionEditorViewModel = makeConditionEditorViewModel
        self.makeConditionDetailViewModel = makeConditionDetailViewModel
        self.makeRecordEditorViewModel = makeRecordEditorViewModel
    }

    var body: some View {
        Group {
            if let error = viewModel.error {
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !viewModel.conditions.isEmpty {
                    Button(listEditMode.isEditing ? "完成" : "排序") {
                        withAnimation {
                            listEditMode = listEditMode.isEditing ? .inactive : .active
                        }
                    }
                }

                Menu {
                    Button {
                        isPresentingWishEditor = true
                    } label: {
                        Label("编辑心愿", systemImage: "pencil")
                    }

                    switch viewModel.wish.status {
                    case .active:
                        Button {
                            viewModel.pauseWish()
                        } label: {
                            Label("暂停心愿", systemImage: "pause.circle")
                        }

                        Button {
                            viewModel.archiveWish()
                        } label: {
                            Label("归档心愿", systemImage: "archivebox")
                        }
                    case .paused:
                        Button {
                            viewModel.resumeWish()
                        } label: {
                            Label("恢复心愿", systemImage: "play.circle")
                        }

                        Button {
                            viewModel.archiveWish()
                        } label: {
                            Label("归档心愿", systemImage: "archivebox")
                        }
                    case .unlocked, .completed, .archived:
                        EmptyView()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("更多操作")
            }
        }
        .sheet(
            isPresented: $isPresentingNewCondition,
            onDismiss: {
                viewModel.load()
            }
        ) {
            ConditionEditorView(
                viewModel: makeConditionEditorViewModel(nil, viewModel.nextSortOrder)
            )
        }
        .sheet(
            isPresented: $isPresentingWishEditor,
            onDismiss: {
                viewModel.load()
            }
        ) {
            WishEditorView(viewModel: makeWishEditorViewModel(viewModel.wish))
        }
        .sheet(
            item: $editingCondition,
            onDismiss: {
                viewModel.load()
            }
        ) { condition in
            ConditionEditorView(
                viewModel: makeConditionEditorViewModel(condition, condition.sortOrder)
            )
        }
        .sheet(
            item: $recordCondition,
            onDismiss: {
                viewModel.load()
            }
        ) { condition in
            RecordEditorView(
                viewModel: makeRecordEditorViewModel(condition, nil)
            )
        }
        .navigationDestination(isPresented: $isShowingConditionDetail) {
            if let condition = selectedCondition {
                ConditionDetailView(
                    viewModel: makeConditionDetailViewModel(condition),
                    makeRecordEditorViewModel: { record in
                        makeRecordEditorViewModel(condition, record)
                    }
                )
            }
        }
        .confirmationDialog(
            "删除条件？",
            isPresented: Binding(
                get: { conditionPendingDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        conditionPendingDeletion = nil
                    }
                }
            ),
            presenting: conditionPendingDeletion
        ) { condition in
            Button("删除", role: .destructive) {
                viewModel.deleteCondition(condition)
                conditionPendingDeletion = nil
            }
            Button("取消", role: .cancel) {
                conditionPendingDeletion = nil
            }
        } message: { condition in
            Text("删除「\(condition.title)」后，关联的行动记录也会被删除。")
        }
        .appErrorAlert(error: $viewModel.actionError)
        .onAppear {
            viewModel.load()
        }
        .onChange(of: unlockCoordinator.presentation?.id) { oldValue, newValue in
            // The detail remains mounted behind the full-screen celebration.
            // Reload after claim/dismiss so the underlying screen shows the
            // authoritative completed or unlocked state.
            if oldValue != nil && newValue == nil {
                viewModel.load()
            }
        }
    }

    private var content: some View {
        List {
            Section {
                WishDetailHero(
                    wish: viewModel.wish,
                    imageData: viewModel.imageData,
                    progressSummary: viewModel.progressSummary,
                    hasOptionalConditionsOnly: viewModel.hasOptionalConditionsOnly,
                    onAddCondition: {
                        isPresentingNewCondition = true
                    }
                )
                .listRowInsets(
                    EdgeInsets(
                        top: AppSpacing.sm,
                        leading: AppSpacing.screenInset,
                        bottom: AppSpacing.sm,
                        trailing: AppSpacing.screenInset
                    )
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if viewModel.wish.status == .paused {
                Section {
                    PausedWishCard(onResume: viewModel.resumeWish)
                        .listRowInsets(
                            EdgeInsets(
                                top: AppSpacing.xs,
                                leading: AppSpacing.screenInset,
                                bottom: AppSpacing.xs,
                                trailing: AppSpacing.screenInset
                            )
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }

            if viewModel.wish.status == .unlocked {
                Section {
                    claimButton
                        .listRowInsets(
                            EdgeInsets(
                                top: AppSpacing.xs,
                                leading: AppSpacing.screenInset,
                                bottom: AppSpacing.xs,
                                trailing: AppSpacing.screenInset
                            )
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }

            if !viewModel.conditions.isEmpty {
                Section {
                    ForEach(viewModel.conditions) { condition in
                        conditionRow(condition)
                    }
                    .onMove { source, destination in
                        viewModel.moveConditions(from: source, to: destination)
                    }
                } header: {
                    conditionsHeader
                }
            }

            if !viewModel.recentRecords.isEmpty {
                Section {
                    recentRecordsCard
                        .listRowInsets(
                            EdgeInsets(
                                top: AppSpacing.xs,
                                leading: AppSpacing.screenInset,
                                bottom: AppSpacing.xl,
                                trailing: AppSpacing.screenInset
                            )
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } header: {
                    EditorialSectionHeader(
                        title: "最近的努力",
                        detail: "\(viewModel.recentRecords.count)",
                        showsSparkle: false
                    )
                    .textCase(nil)
                    .padding(.horizontal, AppSpacing.screenInset)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xs)
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(AppSpacing.lg)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $listEditMode)
        .appScreenBackground()
    }

    private var conditionsHeader: some View {
        HStack(alignment: .center, spacing: AppSpacing.sm) {
            EditorialSectionHeader(
                title: "解锁条件",
                detail: "\(viewModel.conditions.count)",
                showsSparkle: false
            )

            Button {
                isPresentingNewCondition = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 34, height: 34)
                    .background(AppColors.primarySoft, in: Circle())
            }
            .buttonStyle(.pressableChip)
            .frame(
                minWidth: AppLayout.touchTarget,
                minHeight: AppLayout.touchTarget
            )
            .accessibilityLabel("添加条件")
        }
        .textCase(nil)
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xs)
    }

    private var claimButton: some View {
        Button {
            viewModel.completeWish()
        } label: {
            Label("领取这份奖励", systemImage: "sparkles")
        }
        .buttonStyle(.appPrimary)
    }

    private func conditionRow(_ condition: Condition) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Button {
                selectedCondition = condition
                isShowingConditionDetail = true
            } label: {
                ConditionRow(
                    condition: condition,
                    snapshot: viewModel.snapshot(for: condition),
                    theme: .forWish(viewModel.wish)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityHint("打开条件详情")

            if viewModel.canRecord(for: condition) {
                recordButton(for: condition)
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
        .listRowInsets(
            EdgeInsets(
                top: AppSpacing.xs + 1,
                leading: AppSpacing.screenInset,
                bottom: AppSpacing.xs + 1,
                trailing: AppSpacing.screenInset
            )
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                conditionPendingDeletion = condition
            } label: {
                Label("删除", systemImage: "trash")
            }

            Button {
                editingCondition = condition
            } label: {
                Label("编辑", systemImage: "pencil")
            }
            .tint(AppColors.accent)
        }
        .contextMenu {
            Button {
                editingCondition = condition
            } label: {
                Label("编辑", systemImage: "pencil")
            }

            Button(role: .destructive) {
                conditionPendingDeletion = condition
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private func recordButton(for condition: Condition) -> some View {
        Button {
            recordCondition = condition
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))

                Text("记录")
                    .font(AppTypography.caption.weight(.semibold))
            }
            .foregroundStyle(AppColors.primary)
            .padding(.horizontal, AppSpacing.sm + 2)
            .frame(minHeight: AppLayout.touchTarget)
            .background(AppColors.primarySoft, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.pressableChip)
        .accessibilityLabel("记录\(condition.title)")
    }

    private var recentRecordsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.recentRecords.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Rectangle()
                        .fill(AppColors.separator)
                        .frame(height: 0.5)
                }

                RecentRecordRow(item: item)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.xs)
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.separator, lineWidth: 0.8)
        }
    }
}

private struct WishDetailHero: View {
    let wish: Wish
    let imageData: Data?
    let progressSummary: WishProgressSummary?
    let hasOptionalConditionsOnly: Bool
    let onAddCondition: () -> Void

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            heroImage
            info
        }
        .background(
            AppColors.surface,
            in: RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xxl, style: .continuous)
                .stroke(AppColors.separator, lineWidth: 0.8)
        }
    }

    private var heroImage: some View {
        Color.clear
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .overlay {
                WishPhotoView(
                    imageData: imageData,
                    theme: theme,
                    cornerRadius: AppRadius.xl,
                    iconSize: 44
                )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
            )
            .overlay(alignment: .topLeading) {
                StatusBadge(
                    title: wish.status.displayName,
                    tone: wish.status.badgeTone,
                    style: .pill
                )
                .padding(AppSpacing.lg + AppSpacing.xs)
            }
            .padding(10)
            .accessibilityHidden(true)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .center, spacing: AppSpacing.sm) {
                KickerText(
                    text: "我的心愿",
                    color: theme.labelText,
                    tracking: 1.0
                )

                Spacer(minLength: AppSpacing.sm)

                WishThemeMark(theme: theme, width: 24)
            }

            Text(wish.title)
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            metaContent

            if let progressSummary {
                progressPanel(progressSummary)
                    .padding(.top, AppSpacing.xs)
            } else {
                emptyProgressSection
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.lg + AppSpacing.xs)
        .padding(.top, AppSpacing.sm)
    }

    @ViewBuilder
    private var metaContent: some View {
        let priceText = wish.targetPrice.map {
            $0.formatted(
                .currency(code: wish.currencyCode)
                .locale(Locale(identifier: "zh_CN"))
            )
        }
        let targetDateText = wish.targetDate.map {
            $0.formatted(
                .dateTime.year().month().day()
                    .locale(Locale(identifier: "zh_CN"))
            )
        }
        let completedText = wish.completedAt.map {
            $0.formatted(
                .dateTime.year().month().day()
                    .locale(Locale(identifier: "zh_CN"))
            )
        }

        if priceText != nil || targetDateText != nil || completedText != nil {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppSpacing.sm) {
                    metaItems(
                        priceText: priceText,
                        targetDateText: targetDateText,
                        completedText: completedText
                    )
                }

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    metaItems(
                        priceText: priceText,
                        targetDateText: targetDateText,
                        completedText: completedText
                    )
                }
            }
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
        }
    }

    @ViewBuilder
    private func metaItems(
        priceText: String?,
        targetDateText: String?,
        completedText: String?
    ) -> some View {
        if let priceText {
            Text(priceText)
        }
        if let targetDateText {
            Text("目标 \(targetDateText)")
        }
        if let completedText {
            Text("完成于 \(completedText)")
        }
    }

    private func progressPanel(_ summary: WishProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                Text("离心愿还有多远")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer(minLength: AppSpacing.sm)

                Text(summary.detailText)
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.trailing)
            }

            ProgressIndicator(
                value: summary.ratio,
                accessibilityLabel: "条件进度",
                accessibilityValue: summary.accessibilityValue,
                style: .hero,
                isComplete: summary.isComplete
            )
        }
        .padding(AppSpacing.md + 2)
        .background(
            AppColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(AppColors.separator, lineWidth: 0.8)
        }
    }

    private var emptyProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(hasOptionalConditionsOnly ? "还没有必需条件" : "还没有解锁条件")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("为这个心愿添加一个可以努力的方向。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if wish.status == .active {
                Button(action: onAddCondition) {
                    Label("添加第一个解锁条件", systemImage: "plus")
                        .font(AppTypography.callout.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(minHeight: AppLayout.touchTarget)
                        .background(AppColors.primarySoft, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.pressableChip)
                .padding(.top, AppSpacing.xxs)
            }
        }
    }
}

private struct PausedWishCard: View {
    let onResume: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "pause.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.warning)
                    .accessibilityHidden(true)

                Text("这个心愿已暂停")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Text("已有进度和记录会保留，准备好后可以继续。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button("恢复心愿", action: onResume)
                .buttonStyle(.appPrimary)
                .padding(.top, AppSpacing.sm)
        }
        .padding(AppSpacing.lg)
        .appCard(radius: AppRadius.card)
    }
}

private struct RecentRecordRow: View {
    let item: WishRecentRecord

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.conditionTitle)
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(
                    item.record.recordedAt.formatted(
                        .dateTime.year().month().day().hour().minute()
                            .locale(Locale(identifier: "zh_CN"))
                    )
                )
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

                if let note = item.record.note, !note.isEmpty {
                    Text(note)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: AppSpacing.sm)

            Text(item.valueText)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primary)
        }
        .padding(.vertical, AppSpacing.sm)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let container = AppContainer.preview()
    let wish = try? Wish(title: "Kindle Paperwhite", createdAt: .now, updatedAt: .now)
    NavigationStack {
        if let wish {
            WishDetailView(
                viewModel: container.makeWishDetailViewModel(wish: wish),
                makeWishEditorViewModel: { container.makeWishEditorViewModel(wish: $0) },
                makeConditionEditorViewModel: { condition, sortOrder in
                    container.makeConditionEditorViewModel(
                        wishID: wish.id,
                        condition: condition,
                        sortOrder: sortOrder
                    )
                },
                makeConditionDetailViewModel: container.makeConditionDetailViewModel(condition:),
                makeRecordEditorViewModel: container.makeRecordEditorViewModel(condition:record:)
            )
        }
    }
    .environment(container.unlockCoordinator)
}
