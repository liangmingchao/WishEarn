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
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !viewModel.conditions.isEmpty {
                    Button(listEditMode.isEditing ? "完成" : "编辑") {
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
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if viewModel.wish.status == .paused {
                Section {
                    PausedWishCard(onResume: viewModel.resumeWish)
                        .padding(.horizontal, AppSpacing.screenInset)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }

            if viewModel.wish.status == .unlocked {
                Section {
                    claimButton
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }

            if !viewModel.conditions.isEmpty {
                Section {
                    conditionsHeader
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    ForEach(viewModel.conditions) { condition in
                        conditionRow(condition)
                    }
                    .onMove { source, destination in
                        viewModel.moveConditions(from: source, to: destination)
                    }
                }
            }

            if !viewModel.recentRecords.isEmpty {
                Section {
                    ForEach(viewModel.recentRecords) { item in
                        RecentRecordRow(item: item)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 0,
                                    leading: AppSpacing.screenInset,
                                    bottom: 0,
                                    trailing: AppSpacing.screenInset
                                )
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                } header: {
                    sectionHeader("最近的努力")
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(AppSpacing.md)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $listEditMode)
        .appScreenBackground()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomActionBar
        }
    }

    private var bottomActionBar: some View {
        Group {
            if viewModel.wish.status == .active,
               let recordable = viewModel.conditions.first(
                   where: { viewModel.canRecord(for: $0) }
               ) {
                VStack(spacing: 0) {
                    HairlineDivider()

                    Button("记录这一项进度") {
                        recordCondition = recordable
                    }
                    .buttonStyle(.appPrimary)
                    .padding(.horizontal, AppSpacing.screenInset)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.sm)
                }
                .background(AppColors.canvas)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.kicker)
            .tracking(1)
            .foregroundStyle(AppColors.textTertiary)
            .textCase(nil)
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.top, AppSpacing.md)
    }

    private var conditionsHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("解锁条件")
                .font(AppTypography.kicker)
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)
                .textCase(nil)

            Spacer()

            Button {
                isPresentingNewCondition = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(
                        width: AppLayout.touchTarget,
                        height: AppLayout.touchTarget
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("添加条件")
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private var claimButton: some View {
        Button("领取这份奖励") {
            viewModel.completeWish()
        }
        .buttonStyle(.appPrimary)
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.vertical, AppSpacing.md)
    }

    private func conditionRow(_ condition: Condition) -> some View {
        HStack(spacing: AppSpacing.md) {
            statusMark(for: condition)
                .frame(width: 22, height: 22)

            Button {
                selectedCondition = condition
                isShowingConditionDetail = true
            } label: {
                ConditionRow(
                    condition: condition,
                    snapshot: viewModel.snapshot(for: condition)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityHint("打开条件详情")

            if viewModel.canRecord(for: condition) {
                Button {
                    recordCondition = condition
                } label: {
                    Text("记录")
                        .font(AppTypography.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .overlay(
                            Capsule().stroke(AppColors.separator, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .frame(minWidth: AppLayout.touchTarget, minHeight: AppLayout.touchTarget)
                .accessibilityLabel("记录\(condition.title)")
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: AppSpacing.screenInset,
                bottom: 0,
                trailing: AppSpacing.screenInset
            )
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .overlay(alignment: .bottom) {
            HairlineDivider()
        }
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

    private func statusMark(for condition: Condition) -> some View {
        let isCompleted = viewModel.snapshot(for: condition)?.isCompleted == true

        return Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(
                isCompleted ? AppColors.success : AppColors.textTertiary.opacity(0.55)
            )
            .accessibilityHidden(true)
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
            if let imageData {
                WishHeroPhoto(imageData: imageData, theme: theme)
                    .padding(.top, AppSpacing.sm)
            }

            statusLine
                .padding(.top, AppSpacing.xl)

            Text(wish.title)
                .font(AppTypography.display)
                .tracking(-1.2)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AppSpacing.sm)

            if let progressSummary {
                progressSection(progressSummary)
                    .padding(.top, AppSpacing.lg)
            } else {
                emptyProgressSection
                    .padding(.top, AppSpacing.lg)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.bottom, AppSpacing.sm)
    }

    /// Compact status line: state dot, state, price, and target date.
    private var statusLine: some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)

            Text(wish.status.displayName)
                .font(AppTypography.caption.weight(.semibold))
                .foregroundStyle(statusColor)

            if let price = wish.targetPrice {
                Text("·")
                    .foregroundStyle(AppColors.textTertiary)
                Text(
                    price.formatted(
                        .currency(code: wish.currencyCode)
                        .locale(Locale(identifier: "zh_CN"))
                    )
                )
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            }

            if let targetDate = wish.targetDate {
                Text("·")
                    .foregroundStyle(AppColors.textTertiary)
                Text(
                    targetDate.formatted(
                        .dateTime.year().month().locale(Locale(identifier: "zh_CN"))
                    )
                )
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
            }

            Spacer(minLength: 0)
        }
    }

    private var statusColor: Color {
        switch wish.status {
        case .active:
            return AppColors.chipText
        case .paused:
            return AppColors.warning
        case .unlocked, .completed:
            return AppColors.success
        case .archived:
            return AppColors.textTertiary
        }
    }

    private func progressSection(_ summary: WishProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                Text("已完成 \(summary.completedConditionCount) / \(summary.totalConditionCount) 项条件")
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer(minLength: AppSpacing.sm)

                if !summary.isComplete {
                    Text("还差 \(summary.totalConditionCount - summary.completedConditionCount) 项")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            if summary.totalConditionCount <= 8 {
                SegmentedProgress(
                    completed: summary.completedConditionCount,
                    total: summary.totalConditionCount
                )
            } else {
                ProgressIndicator(
                    value: summary.ratio,
                    accessibilityLabel: "条件进度",
                    accessibilityValue: summary.accessibilityValue,
                    style: .hero,
                    isComplete: summary.isComplete
                )
            }
        }
    }

    private var emptyProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(hasOptionalConditionsOnly ? "还没有必需条件" : "还没有解锁条件")
                .font(AppTypography.callout.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text("为这个心愿添加一个可以努力的方向。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)

            if wish.status == .active {
                Button("添加第一个解锁条件", action: onAddCondition)
                    .buttonStyle(.appSecondary)
                    .padding(.top, AppSpacing.sm)
            }
        }
    }
}

private struct PausedWishCard: View {
    let onResume: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("这个心愿已暂停")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("已有进度和记录会保留，准备好后可以继续。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)

            Button("恢复心愿", action: onResume)
                .buttonStyle(.appPrimary)
                .padding(.top, AppSpacing.sm)
        }
        .padding(AppSpacing.lg)
        .appCard()
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
                .foregroundStyle(AppColors.accent)
        }
        .padding(.vertical, AppSpacing.xs)
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
