import SwiftUI

struct ConditionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ConditionEditorViewModel

    init(viewModel: ConditionEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    EditorField(title: "条件类型") {
                        if viewModel.isEditing {
                            Text(viewModel.type.displayName)
                                .foregroundStyle(AppColors.textSecondary)
                        } else {
                            Picker("条件类型", selection: $viewModel.type) {
                                ForEach(ConditionType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.primary)
                        }
                    }

                    EditorField(title: "条件名称") {
                        TextField("例如：健身", text: $viewModel.title)
                    }

                    EditorField(title: "描述（可选）") {
                        TextField("补充说明", text: $viewModel.descriptionText, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    if viewModel.showsTargetField {
                        EditorField(title: "目标值") {
                            TextField("0", text: $viewModel.targetText)
                                .keyboardType(.decimalPad)
                        }

                        unitField
                    }

                    if viewModel.type == .amount {
                        EditorField(title: "金额方向") {
                            Picker("金额方向", selection: $viewModel.amountDirection) {
                                ForEach(AmountDirection.allCases, id: \.self) { direction in
                                    Text(direction.displayName).tag(direction)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.primary)
                        }
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Toggle("必需条件", isOn: $viewModel.isRequired)
                            .tint(AppColors.primary)
                        Text("MVP 阶段所有条件默认参与解锁判断。")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .appCard()
                }
                .padding(AppSpacing.lg)
            }
            .appScreenBackground()
            .navigationTitle(viewModel.isEditing ? "编辑条件" : "添加条件")
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
            .onChange(of: viewModel.type) { _, _ in
                viewModel.onTypeChanged()
            }
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var unitField: some View {
        switch viewModel.type {
        case .duration:
            EditorField(title: "单位") {
                Picker("单位", selection: $viewModel.unit) {
                    ForEach(viewModel.unitOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
        case .custom:
            EditorField(title: "自定义单位") {
                TextField("例如：页", text: $viewModel.unit)
            }
        default:
            EditorField(title: "单位") {
                Text(viewModel.unit)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    ConditionEditorView(
        viewModel: container.makeConditionEditorViewModel(
            wishID: UUID(),
            condition: nil,
            sortOrder: 0
        )
    )
}
