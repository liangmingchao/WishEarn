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
        VStack(spacing: 0) {
            homeHeader
            filterBar
            content
        }
        .appScreenBackground()
        .navigationTitle("心愿")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Image(systemName: "plus")
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

    private var homeHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("你好")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            Text("今天也要为目标努力。")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
            Text("进行中 \(viewModel.activeWishCount) 个心愿")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(WishFilter.allCases) { filter in
                    Button {
                        viewModel.filter = filter
                    } label: {
                        Text(filter.title)
                            .font(AppTypography.callout)
                            .foregroundStyle(viewModel.filter == filter ? AppColors.onAccent : AppColors.textSecondary)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(viewModel.filter == filter ? AppColors.primary : AppColors.surface)
                            .clipShape(Capsule())
                            .overlay {
                                if viewModel.filter != filter {
                                    Capsule().stroke(AppColors.border, lineWidth: 1)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && !viewModel.hasLoaded {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.error {
            ErrorStateView(
                title: error.title,
                message: error.message,
                onRetry: viewModel.load
            )
        } else if viewModel.filteredWishes.isEmpty {
            VStack(spacing: AppSpacing.lg) {
                EmptyStateView(
                    systemImage: "heart.text.square",
                    title: emptyTitle,
                    message: emptyMessage
                )

                if viewModel.filter == .all {
                    Button("创建第一个心愿") {
                        isPresentingEditor = true
                    }
                    .buttonStyle(.appPrimary)
                    .padding(.horizontal, AppSpacing.xxl)
                }
            }
            .padding(.top, AppSpacing.xxl)
            .frame(maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.filteredWishes) { wish in
                        NavigationLink {
                            WishDetailView(
                                viewModel: makeDetailViewModel(wish),
                                makeConditionEditorViewModel: { condition, sortOrder in
                                    makeConditionEditorViewModel(wish.id, condition, sortOrder)
                                },
                                makeConditionDetailViewModel: makeConditionDetailViewModel,
                                makeRecordEditorViewModel: makeRecordEditorViewModel
                            )
                        } label: {
                            WishCard(
                                wish: wish,
                                conditionCount: viewModel.conditionCount(for: wish),
                                imageData: viewModel.imageData(for: wish),
                                overallProgress: viewModel.overallProgress(for: wish)
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
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
                }
                .padding(AppSpacing.lg)
            }
        }
    }

    private var emptyTitle: String {
        viewModel.filter == .all ? "还没有心愿" : "该分类下暂无心愿"
    }

    private var emptyMessage: String {
        viewModel.filter == .all
            ? "给自己设定一个值得努力的目标吧。"
            : "切换筛选条件，或稍后再来看看。"
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
    }
}
