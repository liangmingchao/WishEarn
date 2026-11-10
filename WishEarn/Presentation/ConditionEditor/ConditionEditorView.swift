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
                    EditorField(
                        title: "条件名称",
                        helperText: viewModel.titleHelperText
                    ) {
                        TextField("例如：健身", text: $viewModel.title)
                            .accessibilityIdentifier("conditionTitleField")
                    }

                    typeField

                    if viewModel.showsTargetField {
                        EditorField(
                            title: viewModel.targetFieldTitle,
                            helperText: viewModel.targetHelperText,
                            errorText: viewModel.targetValidationMessage
                        ) {
                            HStack(
                                alignment: .firstTextBaseline,
                                spacing: AppSpacing.sm
                            ) {
                                TextField("0", text: $viewModel.targetText)
                                    .keyboardType(
                                        viewModel.usesIntegerKeyboard
                                            ? .numberPad
                                            : .decimalPad
                                    )

                                if let unit = viewModel.fixedUnitText {
                                    Text(unit)
                                        .font(AppTypography.callout)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                        }

                        unitField
                    } else {
                        checkpointCard
                    }

                    if viewModel.type == .amount {
                        EditorField(title: "金额方向") {
                            Menu {
                                ForEach(
                                    AmountDirection.allCases,
                                    id: \.self
                                ) { direction in
                                    Button(direction.displayName) {
                                        viewModel.amountDirection = direction
                                    }
                                }
                            } label: {
                                EditorMenuLabel(
                                    title: viewModel.amountDirection.displayName
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("金额方向")
                            .accessibilityValue(
                                viewModel.amountDirection.displayName
                            )
                        }
                    }

                    EditorField(title: "说明（选填）") {
                        TextField(
                            "补充说明",
                            text: $viewModel.descriptionText,
                            axis: .vertical
                        )
                        .lineLimit(2...4)
                    }

                    requiredSection
                }
                .padding(AppSpacing.lg)
            }
            .appScreenBackground()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.isEditing ? "编辑条件" : "添加解锁条件")
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
                    .disabled(!viewModel.canSave)
                }
            }
            .tint(AppColors.primary)
            .appErrorAlert(error: $viewModel.error)
            .environment(\.locale, Locale(identifier: "zh_CN"))
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

    private var typeField: some View {
        EditorField(title: "条件类型") {
            if viewModel.isEditing {
                Text(viewModel.type.displayName)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Menu {
                    ForEach(ConditionType.allCases, id: \.self) { type in
                        Button(type.displayName) {
                            viewModel.type = type
                        }
                    }
                } label: {
                    EditorMenuLabel(title: viewModel.type.displayName)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("conditionTypeField")
                .accessibilityLabel("条件类型")
                .accessibilityValue(viewModel.type.displayName)
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
            EmptyView()
        }
    }

    private var checkpointCard: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppColors.success)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("完成型条件")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.checkpointMessage)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private var requiredSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Toggle("必需条件", isOn: $viewModel.isRequired)
                .tint(AppColors.primary)
            Text("必需条件参与心愿解锁判断；关闭后仅作为可选努力方向。")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCard()
    }
}

private struct EditorMenuLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(title)
                .foregroundStyle(AppColors.textPrimary)
            Spacer(minLength: AppSpacing.sm)
            Image(systemName: "chevron.up.chevron.down")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview("STREAK") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .streak))
}

#Preview("COUNT") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .count))
}

#Preview("DURATION") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .duration))
}

#Preview("AMOUNT") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .amount))
}

#Preview("CHECKPOINT") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .checkpoint))
}

#Preview("CUSTOM") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .custom))
}

#Preview("AMOUNT — 深色") {
    ConditionEditorView(viewModel: makePreviewViewModel(type: .amount))
        .preferredColorScheme(.dark)
}

@MainActor
private func makePreviewViewModel(
    type: ConditionType
) -> ConditionEditorViewModel {
    let container = AppContainer.preview()
    let viewModel = container.makeConditionEditorViewModel(
        wishID: UUID(),
        condition: nil,
        sortOrder: 0
    )
    viewModel.type = type
    viewModel.onTypeChanged()
    return viewModel
}
