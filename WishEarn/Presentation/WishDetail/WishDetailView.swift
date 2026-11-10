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
                    ForEach(viewModel.recentRecords) { item in
                        RecentRecordRow(item: item)
                            .listRowBackground(AppColors.surface)
                    }
                } header: {
                    Text("最近的努力")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $listEditMode)
        .appScreenBackground()
    }

    private var conditionsHeader: some View {
        HStack {
            Text("解锁条件")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button {
                isPresentingNewCondition = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(AppColors.accent)
                    .frame(
                        width: AppLayout.touchTarget,
                        height: AppLayout.touchTarget
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("添加条件")
        }
    }

    private var claimButton: some View {
        Button("领取这份奖励") {
            viewModel.completeWish()
        }
        .buttonStyle(.appPrimary)
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private func conditionRow(_ condition: Condition) -> some View {
        HStack(spacing: AppSpacing.sm) {
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
                Button {
                    recordCondition = condition
                } label: {
                    Text("记录")
                        .font(AppTypography.caption.weight(.semibold))
                        .foregroundStyle(AppColors.accent)
                        .frame(
                            minWidth: AppLayout.touchTarget,
                            minHeight: AppLayout.touchTarget
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("记录\(condition.title)")
            }
        }
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: AppSpacing.lg,
                bottom: 0,
                trailing: AppSpacing.lg
            )
        )
        .listRowBackground(AppColors.surface)
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
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            heroImage
            WishThemeMark(theme: theme)

            Text(wish.title)
                .font(AppTypography.display)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppSpacing.sm) {
                StatusBadge(
                    title: wish.status.displayName,
                    tone: wish.status.badgeTone
                )

                if let price = wish.targetPrice {
                    Text("·")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(
                        price.formatted(
                            .currency(code: wish.currencyCode)
                            .locale(Locale(identifier: "zh_CN"))
                        )
                    )
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }

            if let targetDate = wish.targetDate {
                Text(
                    "目标日期：\(targetDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "zh_CN"))))"
                )
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
            }

            if wish.status == .completed, let completedAt = wish.completedAt {
                Text(
                    "完成于 \(completedAt.formatted(.dateTime.year().month().day().locale(Locale(identifier: "zh_CN"))))"
                )
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
            }

            if let progressSummary {
                progressSection(progressSummary)
            } else {
                emptyProgressSection
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.md)
    }

    private var heroImage: some View {
        ZStack {
            theme.softTint

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(theme.onSoftTint)
            }
        }
        .aspectRatio(16.0 / 10.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
        .accessibilityHidden(true)
    }

    private func progressSection(_ summary: WishProgressSummary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("你的努力")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(summary.detailText)
                .font(AppTypography.callout.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            ProgressIndicator(
                value: summary.ratio,
                accessibilityLabel: "条件进度",
                accessibilityValue: summary.accessibilityValue,
                style: .hero,
                isComplete: summary.isComplete
            )
        }
        .padding(.top, AppSpacing.md)
    }

    private var emptyProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(hasOptionalConditionsOnly ? "还没有必需条件" : "还没有解锁条件")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("为这个心愿添加一个可以努力的方向。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)

            if wish.status == .active {
                Button("添加第一个解锁条件", action: onAddCondition)
                    .buttonStyle(.appPrimary)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .padding(.top, AppSpacing.md)
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
