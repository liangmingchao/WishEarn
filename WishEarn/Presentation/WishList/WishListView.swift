import SwiftUI

struct WishListView: View {
    @State private var viewModel: WishListViewModel
    @State private var isPresentingEditor = false
    @State private var editingWish: Wish?
    @State private var wishPendingDeletion: Wish?

    private let makeEditorViewModel: (Wish?) -> WishEditorViewModel
    private let makeDetailViewModel: (Wish) -> WishDetailViewModel
    private let makeConditionEditorViewModel: (UUID, Condition?, Int) -> ConditionEditorViewModel
    private let makeConditionDetailViewModel: (Condition) -> ConditionDetailViewModel
    private let makeRecordEditorViewModel: (Condition, ProgressRecord?) -> RecordEditorViewModel

    init(
        viewModel: WishListViewModel,
        makeEditorViewModel: @escaping (Wish?) -> WishEditorViewModel,
        makeDetailViewModel: @escaping (Wish) -> WishDetailViewModel,
        makeConditionEditorViewModel: @escaping (UUID, Condition?, Int) -> ConditionEditorViewModel,
        makeConditionDetailViewModel: @escaping (Condition) -> ConditionDetailViewModel,
        makeRecordEditorViewModel: @escaping (Condition, ProgressRecord?) -> RecordEditorViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        self.makeEditorViewModel = makeEditorViewModel
        self.makeDetailViewModel = makeDetailViewModel
        self.makeConditionEditorViewModel = makeConditionEditorViewModel
        self.makeConditionDetailViewModel = makeConditionDetailViewModel
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.wishes.isEmpty {
                firstUseEmptyState
            } else {
                scrollContent
            }
        }
        .appScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(
            isPresented: $isPresentingEditor,
            onDismiss: {
                viewModel.load()
            }
        ) {
            WishEditorView(viewModel: makeEditorViewModel(nil))
        }
        .sheet(
            item: $editingWish,
            onDismiss: {
                viewModel.load()
            }
        ) { wish in
            WishEditorView(viewModel: makeEditorViewModel(wish))
        }
        .confirmationDialog(
            "删除心愿？",
            isPresented: Binding(
                get: { wishPendingDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        wishPendingDeletion = nil
                    }
                }
            ),
            presenting: wishPendingDeletion
        ) { wish in
            Button("删除", role: .destructive) {
                viewModel.delete(wish)
                wishPendingDeletion = nil
            }
            Button("取消", role: .cancel) {
                wishPendingDeletion = nil
            }
        } message: { wish in
            Text("「\(wish.title)」删除后不可恢复，关联条件与记录也会被删除。")
        }
        .appErrorAlert(error: $viewModel.actionError)
        .onAppear {
            viewModel.load()
        }
    }

    // MARK: - Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                chipBar
                    .padding(.top, AppSpacing.lg)

                if let featuredWish {
                    wishLink(for: featuredWish) {
                        WishCard(
                            wish: featuredWish,
                            progressSummary: viewModel.progressSummary(for: featuredWish),
                            imageData: viewModel.imageData(for: featuredWish)
                        )
                    }
                    .padding(.horizontal, AppSpacing.screenInset)
                    .padding(.top, AppSpacing.md)
                }

                sectionHeader
                    .padding(.top, AppSpacing.section)
                    .padding(.horizontal, AppSpacing.screenInset)

                if secondaryWishes.isEmpty {
                    Text(emptyListMessage)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.screenInset)
                        .padding(.top, AppSpacing.sm)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(secondaryWishes.enumerated()), id: \.element.id) { index, wish in
                            if index > 0 {
                                Rectangle()
                                    .fill(AppColors.separatorSoft)
                                    .frame(height: 0.5)
                                    .padding(.leading, AppLayout.thumbnailSize + AppSpacing.md + 2)
                            }

                            wishLink(for: wish) {
                                WishRow(
                                    wish: wish,
                                    progressSummary: viewModel.progressSummary(for: wish),
                                    imageData: viewModel.imageData(for: wish)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenInset)
                }

                Button {
                    isPresentingEditor = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("新建心愿")
                            .font(AppTypography.callout.weight(.medium))
                    }
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: AppLayout.touchTarget)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .strokeBorder(
                                AppColors.separator,
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppSpacing.screenInset)
                .padding(.top, AppSpacing.section)
            }
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xxl + AppSpacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 5) {
                Text(headerDateText)
                    .font(AppTypography.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(AppColors.textTertiary)

                Text("心愿")
                    .font(AppTypography.pageTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text(
                    viewModel.activeWishCount > 0
                        ? "为 \(viewModel.activeWishCount) 个想要的东西努力着"
                        : "先收藏一件真正想要的东西"
                )
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.top, 1)
            }

            Spacer(minLength: AppSpacing.sm)

            Button {
                isPresentingEditor = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.onPrimary)
                    .frame(width: 42, height: 42)
                    .background(AppColors.primary, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("创建心愿")
            .accessibilityIdentifier("homeCreateWishButton")
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.md)
    }

    private var chipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(HomeFilter.allCases) { item in
                    HomeFilterChip(
                        title: item.title,
                        count: count(for: item),
                        isSelected: viewModel.filter == item.filter
                    ) {
                        withAnimation(AppMotion.quick) {
                            viewModel.filter = item.filter
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.vertical, 2)
        }
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(sectionTitle)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Text("\(secondaryWishes.count) 个")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var firstUseEmptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                EmptyStateView(
                    systemImage: "heart.text.square",
                    title: "给自己一个值得期待的目标",
                    message: "选一件真正想要的东西，再决定要为它付出哪些努力。",
                    actionTitle: "创建第一个心愿",
                    action: {
                        isPresentingEditor = true
                    }
                )
                .padding(.top, AppSpacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
    }

    private func wishLink<Label: View>(
        for wish: Wish,
        @ViewBuilder label: () -> Label
    ) -> some View {
        NavigationLink {
            WishDetailView(
                viewModel: makeDetailViewModel(wish),
                makeWishEditorViewModel: { makeEditorViewModel($0) },
                makeConditionEditorViewModel: { condition, sortOrder in
                    makeConditionEditorViewModel(wish.id, condition, sortOrder)
                },
                makeConditionDetailViewModel: makeConditionDetailViewModel,
                makeRecordEditorViewModel: makeRecordEditorViewModel
            )
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("wishCard-\(wish.title)")
        .contextMenu {
            wishContextMenu(for: wish)
        }
    }

    @ViewBuilder
    private func wishContextMenu(for wish: Wish) -> some View {
        if wish.status == .active {
            Button {
                viewModel.pause(wish)
            } label: {
                Label("暂停", systemImage: "pause.circle")
            }
        }

        if wish.status == .paused {
            Button {
                viewModel.resume(wish)
            } label: {
                Label("恢复", systemImage: "play.circle")
            }
        }

        if wish.status == .unlocked {
            Button {
                viewModel.complete(wish)
            } label: {
                Label("兑现奖励", systemImage: "checkmark.seal")
            }
        }

        if wish.status == .active || wish.status == .paused {
            Button {
                viewModel.archive(wish)
            } label: {
                Label("归档", systemImage: "archivebox")
            }
        }

        Button {
            editingWish = wish
        } label: {
            Label("编辑", systemImage: "pencil")
        }

        Button(role: .destructive) {
            wishPendingDeletion = wish
        } label: {
            Label("删除", systemImage: "trash")
        }
    }

    // MARK: - Derived data

    /// Home hides archived and already-claimed wishes from the default list so
    /// the first screen stays about what is still in motion.
    private var visibleWishes: [Wish] {
        switch viewModel.filter {
        case .all:
            return viewModel.wishes.filter {
                $0.status != .completed && $0.status != .archived
            }
        case .completed:
            return viewModel.wishes.filter { $0.status == .completed }
        default:
            return viewModel.filteredWishes
        }
    }

    private var featuredWish: Wish? {
        guard viewModel.filter == .all || viewModel.filter == .active else {
            return nil
        }
        return visibleWishes
            .filter { $0.status == .active }
            .max { lhs, rhs in
                (viewModel.overallProgress(for: lhs) ?? 0)
                    < (viewModel.overallProgress(for: rhs) ?? 0)
            }
    }

    private var secondaryWishes: [Wish] {
        guard let featuredWish else { return visibleWishes }
        return visibleWishes.filter { $0.id != featuredWish.id }
    }

    private func count(for item: HomeFilter) -> Int {
        viewModel.wishes.filter { wish in
            switch item {
            case .all:
                return wish.status != .completed && wish.status != .archived
            case .active:
                return wish.status == .active
            case .unlocked:
                return wish.status == .unlocked
            case .completed:
                return wish.status == .completed
            }
        }.count
    }

    private var sectionTitle: String {
        switch viewModel.filter {
        case .completed:
            return "已兑现的心愿"
        case .unlocked:
            return "已解锁 · 等待领取"
        default:
            return featuredWish == nil ? "全部心愿" : "其他心愿"
        }
    }

    private var emptyListMessage: String {
        viewModel.filter == .completed
            ? "还没有兑现的心愿。慢慢来。"
            : "这个分类下还没有心愿。"
    }

    private var headerDateText: String {
        let locale = Locale(identifier: "zh_CN")
        let monthDay = Date.now.formatted(
            .dateTime.month(.defaultDigits).day().locale(locale)
        )
        let weekday = Date.now.formatted(
            .dateTime.weekday(.wide).locale(locale)
        )
        return "\(monthDay) · \(weekday)"
    }
}

// MARK: - Filters

private enum HomeFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case unlocked
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .active: return "进行中"
        case .unlocked: return "已解锁"
        case .completed: return "已兑现"
        }
    }

    var filter: WishFilter {
        switch self {
        case .all: return .all
        case .active: return .active
        case .unlocked: return .unlocked
        case .completed: return .completed
        }
    }
}

private struct HomeFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))

                Text("\(count)")
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .opacity(isSelected ? 0.62 : 0.55)
            }
            .foregroundStyle(isSelected ? AppColors.canvas : AppColors.textSecondary)
            .padding(.horizontal, 13)
            .frame(height: 34)
            .background {
                if isSelected {
                    Capsule().fill(AppColors.textPrimary)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .overlay(
                            Capsule().stroke(AppColors.separator, lineWidth: 1)
                        )
                }
            }
            .frame(minHeight: AppLayout.touchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("\(title)，\(count) 个"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        WishListView(
            viewModel: container.makeWishListViewModel(),
            makeEditorViewModel: container.makeWishEditorViewModel(wish:),
            makeDetailViewModel: container.makeWishDetailViewModel(wish:),
            makeConditionEditorViewModel: container.makeConditionEditorViewModel(wishID:condition:sortOrder:),
            makeConditionDetailViewModel: container.makeConditionDetailViewModel(condition:),
            makeRecordEditorViewModel: container.makeRecordEditorViewModel(condition:record:)
        )
        .environment(container.unlockCoordinator)
    }
}
