import SwiftUI
import UIKit

struct WishDetailView: View {
    @State private var viewModel: WishDetailViewModel
    @State private var isPresentingNewCondition = false
    @State private var editingCondition: Condition?
    @State private var conditionPendingDeletion: Condition?

    private let makeConditionEditorViewModel: (Condition?, Int) -> ConditionEditorViewModel
    private let makeConditionDetailViewModel: (Condition) -> ConditionDetailViewModel
    private let makeRecordEditorViewModel: (Condition, ProgressRecord?) -> RecordEditorViewModel

    init(
        viewModel: WishDetailViewModel,
        makeConditionEditorViewModel: @escaping (Condition?, Int) -> ConditionEditorViewModel,
        makeConditionDetailViewModel: @escaping (Condition) -> ConditionDetailViewModel,
        makeRecordEditorViewModel: @escaping (Condition, ProgressRecord?) -> RecordEditorViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
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
        .navigationTitle(viewModel.wish.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !viewModel.conditions.isEmpty {
                    EditButton()
                }

                Button {
                    isPresentingNewCondition = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("添加条件")
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
            item: $editingCondition,
            onDismiss: {
                viewModel.load()
            }
        ) { condition in
            ConditionEditorView(
                viewModel: makeConditionEditorViewModel(condition, condition.sortOrder)
            )
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
        .task {
            viewModel.load()
        }
    }

    private var content: some View {
        List {
            Section {
                WishDetailHeader(
                    wish: viewModel.wish,
                    imageData: viewModel.imageData,
                    overallRatio: viewModel.progress?.overallRatio
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if viewModel.wish.status == .unlocked {
                Section {
                    Button("我已领取奖励") {
                        viewModel.completeWish()
                    }
                    .buttonStyle(.appPrimary)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }

            Section("解锁条件") {
                if viewModel.conditions.isEmpty {
                    Text("还没有条件，点击右上角 + 添加一个开始吧。")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    ForEach(viewModel.conditions) { condition in
                        NavigationLink {
                            ConditionDetailView(
                                viewModel: makeConditionDetailViewModel(condition),
                                makeRecordEditorViewModel: { record in
                                    makeRecordEditorViewModel(condition, record)
                                }
                            )
                        } label: {
                            ConditionRow(
                                condition: condition,
                                snapshot: viewModel.snapshot(for: condition)
                            )
                        }
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
                            .tint(AppColors.primary)
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
                    .onMove { source, destination in
                        viewModel.moveConditions(from: source, to: destination)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appScreenBackground()
    }
}

private struct WishDetailHeader: View {
    let wish: Wish
    let imageData: Data?
    let overallRatio: Double?

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.lg) {
            thumbnail

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(wish.title)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)

                StatusBadge(title: wish.status.displayName, tone: wish.status.badgeTone)

                if let price = wish.targetPrice {
                    Text(price.formatted(.currency(code: wish.currencyCode).locale(Locale(identifier: "zh_CN"))))
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if let targetDate = wish.targetDate {
                    Text("目标日期：\(targetDate.formatted(.dateTime.year().month().day().locale(Locale(identifier: "zh_CN"))))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if let overallRatio {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Text("总体进度")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                            Spacer()
                            Text("\(Int(overallRatio * 100))%")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.primary)
                        }
                        ProgressView(value: overallRatio)
                            .tint(AppColors.primary)
                    }
                }
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .appCard()
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.primarySoft)
                Image(systemName: "heart.fill")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(AppColors.primary)
            }
            .frame(width: 80, height: 80)
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    let wish = try? Wish(title: "Kindle Paperwhite", createdAt: .now, updatedAt: .now)
    NavigationStack {
        if let wish {
            WishDetailView(
                viewModel: container.makeWishDetailViewModel(wish: wish),
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
}
