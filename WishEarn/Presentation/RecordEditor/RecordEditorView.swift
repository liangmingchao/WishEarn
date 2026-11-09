import SwiftUI

struct RecordEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecordEditorViewModel

    init(viewModel: RecordEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    conditionCard

                    if viewModel.showsValueField {
                        EditorField(title: viewModel.valueLabel) {
                            TextField("0", text: $viewModel.valueText)
                                .keyboardType(.decimalPad)
                        }
                    } else {
                        EditorField(title: "记录方式") {
                            Text(viewModel.isEditing ? "修改完成状态记录" : "保存后记录为已完成")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    if let direction = viewModel.amountDirectionText {
                        Text("金额方向：\(direction)")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    EditorField(title: "备注（可选）") {
                        TextField("补充说明", text: $viewModel.noteText, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("记录时间")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        DatePicker(
                            "记录时间",
                            selection: $viewModel.recordedAt,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }
                    .appCard()
                }
                .padding(AppSpacing.lg)
            }
            .appScreenBackground()
            .navigationTitle(viewModel.isEditing ? "编辑记录" : "添加记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.save()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .tint(AppColors.primary)
            .appErrorAlert(error: $viewModel.error)
            .interactiveDismissDisabled(viewModel.isSaving)
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }

    private var conditionCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.conditionTitle)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text(viewModel.conditionSummary)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}
