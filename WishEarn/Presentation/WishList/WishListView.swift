import SwiftUI

struct WishListView: View {
    @State private var viewModel: WishListViewModel
    @State private var isPresentingEditor = false
    @State private var editingWish: Wish?
    @State private var wishPendingDeletion: Wish?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
            } else {
                wishContent
            }
        }
        .appScreenBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 34, height: 34)
                        .background(AppColors.primarySoft, in: Circle())
                        .contentShape(Circle())
                }
                .accessibilityLabel("创建心愿")
            }
        }
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

    private var wishContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header

                if showsFilterBar {
                    filterBar
                }

                if viewModel.wishes.isEmpty {
                    firstUseEmptyState
                } else if viewModel.filteredWishes.isEmpty {
                    filterEmptyState
                } else {
                    wishListContent
                }
            }
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxl)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            KickerText(text: "心愿手账")

            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                Text("我的心愿")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColors.textPrimary)

                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.coral)
                    .accessibilityHidden(true)
            }

            if viewModel.hasLoaded && viewModel.activeWishCount > 0 {
                Text("正在为 \(viewModel.activeWishCount) 个想要的东西努力")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private var showsFilterBar: Bool {
        viewModel.hasLoaded
            && viewModel.error == nil
            && !viewModel.wishes.isEmpty
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(WishFilter.allCases) { filter in
                    FilterChip(
                        title: filter.title,
                        isSelected: viewModel.filter == filter
                    ) {
                        withAnimation(AppMotion.standard) {
                            viewModel.filter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenInset)
        }
    }

    private var firstUseEmptyState: some View {
        EmptyStateView(
            systemImage: "heart.text.square",
            title: "给自己一个值得期待的目标",
            message: "选一件真正想要的东西，再决定要为它付出哪些努力。",
            actionTitle: "创建第一个心愿",
            action: {
                isPresentingEditor = true
            }
        )
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xl)
    }

    private var filterEmptyState: some View {
        EmptyStateView(
            systemImage: "line.3.horizontal.decrease.circle",
            title: "这里暂时没有心愿",
            message: "「\(viewModel.filter.title)」筛选下还没有心愿。",
            actionTitle: "查看全部",
            action: {
                withAnimation(AppMotion.standard) {
                    viewModel.filter = .all
                }
            }
        )
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.xl)
    }

    private var wishListContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            if let featuredWish = viewModel.featuredWish {
                wishLink(for: featuredWish) {
                    FeaturedWishCard(
                        wish: featuredWish,
                        progressSummary: viewModel.progressSummary(for: featuredWish),
                        imageData: viewModel.imageData(for: featuredWish)
                    )
                }
            }

            let secondaryWishes = viewModel.secondaryWishes
            if !secondaryWishes.isEmpty {
                secondarySection(secondaryWishes)
            }
        }
        .padding(.horizontal, AppSpacing.screenInset)
    }

    private func secondarySection(_ wishes: [Wish]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if viewModel.featuredWish != nil {
                EditorialSectionHeader(
                    title: "其他心愿",
                    detail: "\(wishes.count)"
                )
            } else {
                EditorialSectionHeader(
                    title: viewModel.filter == .all
                        ? "全部心愿"
                        : viewModel.filter.title,
                    detail: "\(wishes.count)"
                )
            }

            if let spotlight = wishes.first {
                wishLink(for: spotlight) {
                    WishSpotlightCard(
                        wish: spotlight,
                        progressSummary: viewModel.progressSummary(for: spotlight),
                        imageData: viewModel.imageData(for: spotlight)
                    )
                }
            }

            let gridWishes = Array(wishes.dropFirst())
            if !gridWishes.isEmpty {
                LazyVGrid(
                    columns: gridColumns,
                    alignment: .leading,
                    spacing: AppSpacing.md
                ) {
                    ForEach(gridWishes) { wish in
                        wishLink(for: wish) {
                            WishGridCard(
                                wish: wish,
                                progressSummary: viewModel.progressSummary(for: wish),
                                imageData: viewModel.imageData(for: wish)
                            )
                        }
                    }
                }
            }
        }
    }

    private var gridColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible(), spacing: AppSpacing.md)]
        }
        return [
            GridItem(.flexible(), spacing: AppSpacing.md),
            GridItem(.flexible(), spacing: AppSpacing.md)
        ]
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
        .buttonStyle(.pressableCard)
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
