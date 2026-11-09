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
                        valueField
                    } else {
                        completionCard
                    }

                    moreInfoSection
                }
                .padding(AppSpacing.lg)
            }
            .appScreenBackground()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.isEditing ? "编辑记录" : "记录行动")
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
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }

    private var conditionCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("条件")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)

            Text(viewModel.conditionTitle)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text(viewModel.conditionSummary)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            if let direction = viewModel.amountDirectionText {
                Text("金额方向：\(direction)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private var valueField: some View {
        EditorField(
            title: viewModel.valueLabel,
            errorText: viewModel.valueValidationMessage
        ) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                TextField("0", text: $viewModel.valueText)
                    .keyboardType(.decimalPad)

                if let unit = viewModel.valueUnit {
                    Text(unit)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var completionCard: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(AppColors.success)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(viewModel.completionTitle)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.completionMessage)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private var moreInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("更多信息")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            EditorField(title: "备注（选填）") {
                TextField(
                    "补充说明",
                    text: $viewModel.noteText,
                    axis: .vertical
                )
                .lineLimit(2...4)
            }

            EditorField(title: "记录时间") {
                DatePicker(
                    "记录时间",
                    selection: $viewModel.recordedAt,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
            }
        }
    }
}

#Preview("COUNT") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .count) {
        RecordEditorView(viewModel: viewModel)
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("STREAK") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .streak) {
        RecordEditorView(viewModel: viewModel)
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("DURATION") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .duration) {
        RecordEditorView(viewModel: viewModel)
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("AMOUNT") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .amount) {
        RecordEditorView(viewModel: viewModel)
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("CHECKPOINT") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .checkpoint) {
        RecordEditorView(viewModel: viewModel)
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("CUSTOM") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .custom) {
        RecordEditorView(viewModel: viewModel)
    } else {
        Text("Preview data unavailable")
    }
}

#Preview("COUNT — 深色") {
    if let viewModel = makePreviewRecordEditorViewModel(type: .count) {
        RecordEditorView(viewModel: viewModel)
            .preferredColorScheme(.dark)
    } else {
        Text("Preview data unavailable")
    }
}

@MainActor
private func makePreviewRecordEditorViewModel(
    type: ConditionType
) -> RecordEditorViewModel? {
    let title: String
    let targetValue: Decimal
    let unit: String?
    let amountDirection: AmountDirection?

    switch type {
    case .streak:
        title = "不吃零食"
        targetValue = 30
        unit = "天"
        amountDirection = nil
    case .count:
        title = "跑步"
        targetValue = 20
        unit = "次"
        amountDirection = nil
    case .duration:
        title = "阅读"
        targetValue = 30
        unit = "小时"
        amountDirection = nil
    case .amount:
        title = "存钱"
        targetValue = 1000
        unit = "元"
        amountDirection = .saving
    case .checkpoint:
        title = "完成第一版"
        targetValue = 1
        unit = nil
        amountDirection = nil
    case .custom:
        title = "练习"
        targetValue = 300
        unit = "页"
        amountDirection = nil
    }

    guard let condition = try? Condition(
        wishID: UUID(),
        title: title,
        type: type,
        targetValue: targetValue,
        unit: unit,
        amountDirection: amountDirection,
        createdAt: .now
    ) else {
        return nil
    }

    return AppContainer.preview().makeRecordEditorViewModel(
        condition: condition,
        record: nil
    )
}
