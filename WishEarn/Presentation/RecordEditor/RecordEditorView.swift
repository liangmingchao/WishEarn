import SwiftUI

struct RecordEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecordEditorViewModel
    @ScaledMetric(relativeTo: .largeTitle) private var numberSize: CGFloat = 54

    init(viewModel: RecordEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    context

                    if viewModel.showsValueField {
                        valuePad
                            .padding(.top, AppSpacing.xl)
                    } else {
                        completionCard
                            .padding(.top, AppSpacing.xl)
                    }

                    moreInfoSection
                        .padding(.top, AppSpacing.section)
                }
                .padding(.horizontal, AppSpacing.screenInset)
                .padding(.bottom, AppSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .appScreenBackground()
            .navigationTitle(viewModel.isEditing ? "编辑记录" : "记录行动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
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

    // MARK: - Context

    private var context: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(viewModel.conditionTitle)
                .font(AppTypography.wishTitleCompact)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(metaText)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppSpacing.sm)
    }

    private var metaText: String {
        if let direction = viewModel.amountDirectionText {
            return "\(viewModel.conditionSummary) · \(direction)"
        }
        return viewModel.conditionSummary
    }

    // MARK: - Value input

    private var valuePad: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(spacing: 2) {
                Text(viewModel.valueLabel)
                    .font(AppTypography.eyebrow)
                    .tracking(1.4)
                    .foregroundStyle(AppColors.textTertiary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    TextField("0", text: $viewModel.valueText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: numberSize, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(minWidth: 120)
                        .layoutPriority(1)
                        .accessibilityLabel(viewModel.valueLabel)

                    if let unit = viewModel.valueUnit {
                        Text(unit)
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, AppSpacing.xl)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppColors.elevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .stroke(AppColors.separatorSoft, lineWidth: 1)
            )

            if !viewModel.quickAddValues.isEmpty {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Array(viewModel.quickAddValues.enumerated()), id: \.offset) { _, step in
                        Button {
                            viewModel.addValue(step)
                        } label: {
                            Text("+\(plain(step))")
                                .font(.system(size: 13, weight: .semibold))
                                .monospacedDigit()
                                .foregroundStyle(AppColors.primary)
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .background(
                                    AppColors.primarySoft,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("增加 \(plain(step)) \(viewModel.valueUnit ?? "")")
                    }
                }
            }

            if let message = viewModel.valueValidationMessage {
                Text(message)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var completionCard: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AppColors.primary)
                .frame(width: 28, height: 28)
                .background(AppColors.primarySoft, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(viewModel.completionTitle)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.completionMessage)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppColors.elevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppColors.separatorSoft, lineWidth: 1)
        )
    }

    // MARK: - More info

    private var moreInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("更多信息")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("备注 · 选填")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textTertiary)

                TextField(
                    "今天状态怎么样？",
                    text: $viewModel.noteText,
                    axis: .vertical
                )
                .font(AppTypography.callout)
                .lineLimit(2...4)
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppColors.elevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.separatorSoft, lineWidth: 1)
                )
            }

            HStack {
                Text("记录时间")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                DatePicker(
                    "记录时间",
                    selection: $viewModel.recordedAt,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
            }
            .padding(.vertical, AppSpacing.xs)
        }
    }

    // MARK: - Save

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(AppColors.separatorSoft)

            Button {
                viewModel.save()
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(AppColors.onPrimary)
                    }
                    Text(viewModel.isEditing ? "保存修改" : "保存")
                }
            }
            .buttonStyle(.appPrimary)
            .disabled(!viewModel.canSave)
            .opacity(viewModel.canSave ? 1 : 0.42)
            .padding(.horizontal, AppSpacing.screenInset)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.sm)
        }
        .background(.ultraThinMaterial)
    }

    private func plain(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
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
