import SwiftUI

struct ConditionDetailView: View {
    @State private var viewModel: ConditionDetailViewModel
    @State private var isPresentingNewRecord = false
    @State private var editingRecord: ProgressRecord?
    @State private var recordPendingDeletion: ProgressRecord?

    private let makeRecordEditorViewModel: (ProgressRecord?) -> RecordEditorViewModel

    init(
        viewModel: ConditionDetailViewModel,
        makeRecordEditorViewModel: @escaping (ProgressRecord?) -> RecordEditorViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
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
        .navigationTitle(viewModel.condition.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewRecord = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("添加记录")
            }
        }
        .sheet(
            isPresented: $isPresentingNewRecord,
            onDismiss: {
                viewModel.load()
            }
        ) {
            RecordEditorView(viewModel: makeRecordEditorViewModel(nil))
        }
        .sheet(
            item: $editingRecord,
            onDismiss: {
                viewModel.load()
            }
        ) { record in
            RecordEditorView(viewModel: makeRecordEditorViewModel(record))
        }
        .confirmationDialog(
            "删除记录？",
            isPresented: Binding(
                get: { recordPendingDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        recordPendingDeletion = nil
                    }
                }
            ),
            presenting: recordPendingDeletion
        ) { record in
            Button("删除", role: .destructive) {
                viewModel.deleteRecord(record)
                recordPendingDeletion = nil
            }
            Button("取消", role: .cancel) {
                recordPendingDeletion = nil
            }
        } message: { _ in
            Text("删除后累计进度会重新计算，且不可恢复。")
        }
        .appErrorAlert(error: $viewModel.actionError)
        .task {
            viewModel.load()
        }
    }

    private var content: some View {
        List {
            Section {
                summaryCard
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section("行动记录") {
                if viewModel.records.isEmpty {
                    Text("还没有行动记录，点击右上角 + 添加第一条。")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    ForEach(viewModel.records) { record in
                        RecordRow(
                            record: record,
                            conditionType: viewModel.condition.type,
                            unit: viewModel.condition.unit
                        )
                        .listRowBackground(AppColors.surface)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                recordPendingDeletion = record
                            } label: {
                                Label("删除", systemImage: "trash")
                            }

                            Button {
                                editingRecord = record
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }
                            .tint(AppColors.primary)
                        }
                        .contextMenu {
                            Button {
                                editingRecord = record
                            } label: {
                                Label("编辑", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                recordPendingDeletion = record
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .appScreenBackground()
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(viewModel.condition.title)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                if viewModel.condition.isRequired {
                    StatusBadge(title: "必需", tone: .primary)
                }
            }

            Text(viewModel.conditionSummary)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)

            Text(viewModel.summaryText)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primary)

            if let direction = viewModel.condition.amountDirection {
                Text("金额方向：\(direction.displayName)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .appCard()
    }
}

private struct RecordRow: View {
    let record: ProgressRecord
    let conditionType: ConditionType
    let unit: String?

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(record.recordedAt.formatted(
                    .dateTime.year().month().day().hour().minute()
                        .locale(Locale(identifier: "zh_CN"))
                ))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

                if let note = record.note {
                    Text(note)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

            Spacer()

            Text(valueText)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primary)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var valueText: String {
        switch conditionType {
        case .checkpoint:
            return "已完成"
        case .streak:
            return "打卡"
        default:
            let value = NSDecimalNumber(decimal: record.value).stringValue
            if let unit {
                return "\(value) \(unit)"
            }
            return value
        }
    }
}
