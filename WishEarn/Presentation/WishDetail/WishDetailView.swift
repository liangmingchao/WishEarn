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
        .toolbar(.visible, for: .navigationBar)
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomActionBar
        }
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
                .listRowBackground(AppColors.canvas)
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
                            .listRowBackground(AppColors.canvas)
                    }
                } header: {
                    Text("最近的努力")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.textPrimary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(AppSpacing.lg)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $listEditMode)
        .appScreenBackground()
    }

    /// The one action the screen exists for. Hidden while reordering, and only
    /// shown when there is an active wish with something recordable left.
    @ViewBuilder
    private var bottomActionBar: some View {
        if let condition = primaryRecordCondition, !listEditMode.isEditing {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(AppColors.separatorSoft)
                    .frame(height: 0.5)

                Button {
                    recordCondition = condition
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("记录一次行动")
                    }
                }
                .buttonStyle(.appPrimary)
                .padding(.horizontal, AppSpacing.screenInset)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
            }
            .background(.ultraThinMaterial)
        }
    }

    private var primaryRecordCondition: Condition? {
        guard viewModel.wish.status == .active else { return nil }
        return viewModel.conditions.first { viewModel.canRecord(for: $0) }
    }

    private var conditionsHeader: some View {
        HStack {
            Text("解锁条件")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)
                .textCase(nil)

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
                leading: AppSpacing.screenInset,
                bottom: 0,
                trailing: AppSpacing.screenInset
            )
        )
        .listRowBackground(AppColors.canvas)
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

    private var percent: Int {
        Int(((progressSummary?.ratio ?? 0) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    statusPill

                    if let priceText {
                        Text(priceText)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer(minLength: 0)
                }

                Text(wish.title)
                    .font(.system(.title, design: .serif).weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if !metaLine.isEmpty {
                    Text(metaLine)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textTertiary)
                }

                progressBlock
            }
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.top, AppSpacing.lg + 2)
        }
        .padding(.bottom, AppSpacing.sm)
    }

    private var cover: some View {
        Color.clear
            .aspectRatio(1.26, contentMode: .fit)
            .overlay {
                ZStack {
                    WishMonogramPlate(wish: wish, theme: theme, scale: 1.7)

                    if let imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }

    private var statusPill: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(pillForeground)
                .frame(width: 6, height: 6)

            Text(wish.status.displayName)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(pillForeground)
        .padding(.horizontal, 10)
        .frame(height: 26)
        .background(pillBackground, in: Capsule())
        .fixedSize()
    }

    private var pillForeground: Color {
        switch wish.status {
        case .active:
            return AppColors.primary
        case .unlocked:
            return AppColors.coralText
        case .completed:
            return AppColors.success
        case .paused, .archived:
            return AppColors.textSecondary
        }
    }

    private var pillBackground: Color {
        switch wish.status {
        case .active:
            return AppColors.primarySoft
        case .unlocked:
            return AppColors.coralSoft
        case .completed:
            return AppColors.successSoft
        case .paused, .archived:
            return AppColors.surfaceSecondary
        }
    }

    private var priceText: String? {
        guard let price = wish.targetPrice else { return nil }
        return price.formatted(
            .currency(code: wish.currencyCode)
            .locale(Locale(identifier: "zh_CN"))
        )
    }

    private var metaLine: String {
        var parts: [String] = []

        if let targetDate = wish.targetDate {
            parts.append(
                "目标 \(targetDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "zh_CN"))))"
            )
        }

        if wish.status == .completed, let completedAt = wish.completedAt {
            parts.append(
                "完成于 \(completedAt.formatted(.dateTime.year().month().day().locale(Locale(identifier: "zh_CN"))))"
            )
        }

        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private var progressBlock: some View {
        if let progressSummary {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(percent)%")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppColors.textPrimary)

                    Text("完成度")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)

                    Spacer(minLength: AppSpacing.sm)

                    Text("\(progressSummary.completedConditionCount) / \(progressSummary.totalConditionCount) 条件")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }

                ProgressIndicator(
                    value: progressSummary.ratio,
                    accessibilityLabel: "条件进度",
                    accessibilityValue: progressSummary.accessibilityValue,
                    style: .hero,
                    isComplete: progressSummary.isComplete
                )
            }
            .padding(.top, AppSpacing.xs)
        } else {
            emptyProgressSection
        }
    }

    private var emptyProgressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(hasOptionalConditionsOnly ? "还没有必需条件" : "还没有解锁条件")
                .font(AppTypography.sectionTitle)
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
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.elevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.separatorSoft, lineWidth: 1)
        )
        .padding(.top, AppSpacing.xs)
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
