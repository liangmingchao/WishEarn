import Foundation
import Observation

@MainActor
@Observable
final class ConditionEditorViewModel {
    private let wishID: UUID
    private let existingCondition: Condition?
    private let lifecycleService: ConditionLifecycleServicing
    private let sortOrder: Int

    var type: ConditionType = .count
    var title = ""
    var descriptionText = ""
    var targetText = ""
    var unit = "次"
    var amountDirection: AmountDirection = .income
    var isRequired = true

    private(set) var isSaving = false
    private(set) var isSaved = false
    var error: AppError?
    private var previousType: ConditionType = .count

    var isEditing: Bool {
        existingCondition != nil
    }

    var titleHelperText: String? {
        trimmedTitle.isEmpty ? "必填" : nil
    }

    var showsTargetField: Bool {
        type != .checkpoint
    }

    var targetFieldTitle: String {
        switch type {
        case .streak: return "连续天数"
        case .count: return "目标次数"
        case .duration: return "目标时长"
        case .amount: return "目标金额"
        case .custom: return "目标数值"
        case .checkpoint: return ""
        }
    }

    var targetHelperText: String {
        switch type {
        case .streak:
            return "按本地自然日连续计算，必须是正整数。"
        case .count:
            return "完成多少次后达成条件。"
        case .duration:
            return "累计时长达到该值后完成。"
        case .amount:
            return "累计金额达到该值后完成。"
        case .custom:
            return "累计数值达到该值后完成。"
        case .checkpoint:
            return ""
        }
    }

    var targetValidationMessage: String? {
        guard type != .checkpoint else { return nil }

        let trimmed = normalizedTargetText
        guard !trimmed.isEmpty else { return nil }

        guard let parsed = Decimal(
            string: trimmed,
            locale: Locale(identifier: "en_US_POSIX")
        ) else {
            return "目标值必须大于 0。"
        }

        if type == .streak {
            return ConditionTargetValidator.isPositiveInteger(parsed)
                ? nil
                : "连续坚持的目标值必须为正整数。"
        }

        return parsed > 0 ? nil : "目标值必须大于 0。"
    }

    var canSave: Bool {
        guard !isSaving, !trimmedTitle.isEmpty else { return false }
        guard type != .checkpoint else { return true }
        guard !normalizedTargetText.isEmpty else { return false }
        return targetValidationMessage == nil
    }

    var usesIntegerKeyboard: Bool {
        type == .streak
    }

    var fixedUnitText: String? {
        switch type {
        case .count, .streak, .amount:
            return unit
        case .duration, .checkpoint, .custom:
            return nil
        }
    }

    var checkpointMessage: String {
        "完成一次即可达成，无需填写目标值。"
    }

    var unitOptions: [String] {
        ["小时", "分钟"]
    }

    init(
        wishID: UUID,
        lifecycleService: ConditionLifecycleServicing,
        condition: Condition? = nil,
        sortOrder: Int
    ) {
        self.wishID = wishID
        self.lifecycleService = lifecycleService
        self.existingCondition = condition
        self.sortOrder = sortOrder

        if let condition {
            type = condition.type
            title = condition.title
            descriptionText = condition.description ?? ""
            targetText = NSDecimalNumber(decimal: condition.targetValue).stringValue
            unit = condition.unit ?? ""
            amountDirection = condition.amountDirection ?? .income
            isRequired = condition.isRequired
        }

        previousType = type
        normalizeUnitForCurrentType()
    }

    func onTypeChanged() {
        let oldType = previousType
        previousType = type
        normalizeUnitForCurrentType()

        if type == .checkpoint {
            targetText = "1"
        } else if oldType == .checkpoint {
            // The synthetic checkpoint target is not a user-entered numeric
            // value. Do not reinterpret it as a COUNT/DURATION/CUSTOM target.
            targetText = ""
        }
    }

    func save() {
        guard !isSaving else { return }

        error = nil

        guard !trimmedTitle.isEmpty else {
            error = .domain(.invalidInput("请输入条件名称。"))
            return
        }

        let targetValue: Decimal
        if type == .checkpoint {
            targetValue = 1
        } else {
            guard let parsed = Decimal(
                string: normalizedTargetText,
                locale: Locale(identifier: "en_US_POSIX")
            ) else {
                error = .domain(.invalidInput("目标值必须大于 0。"))
                return
            }

            if type == .streak {
                guard ConditionTargetValidator.isPositiveInteger(parsed) else {
                    error = .domain(.invalidInput("连续坚持的目标值必须为正整数。"))
                    return
                }
            } else {
                guard parsed > 0 else {
                    error = .domain(.invalidInput("目标值必须大于 0。"))
                    return
                }
            }

            targetValue = parsed
        }

        let finalDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let direction: AmountDirection? = type == .amount ? amountDirection : nil
        let finalUnit: String?
        if type == .checkpoint {
            finalUnit = nil
        } else {
            let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
            finalUnit = trimmedUnit.isEmpty ? nil : trimmedUnit
        }

        isSaving = true
        defer { isSaving = false }

        do {
            if let existingCondition {
                let updated = try Condition(
                    id: existingCondition.id,
                    wishID: wishID,
                    title: trimmedTitle,
                    description: finalDescription.isEmpty ? nil : finalDescription,
                    type: existingCondition.type,
                    targetValue: targetValue,
                    unit: finalUnit,
                    amountDirection: direction,
                    isRequired: isRequired,
                    sortOrder: existingCondition.sortOrder,
                    createdAt: existingCondition.createdAt
                )
                try lifecycleService.updateCondition(updated)
            } else {
                let draft = ConditionDraft(
                    wishID: wishID,
                    title: trimmedTitle,
                    description: finalDescription.isEmpty ? nil : finalDescription,
                    type: type,
                    targetValue: targetValue,
                    unit: finalUnit,
                    amountDirection: direction,
                    isRequired: isRequired,
                    sortOrder: sortOrder
                )
                _ = try lifecycleService.createCondition(draft)
            }
            isSaved = true
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var normalizedTargetText: String {
        targetText
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizeUnitForCurrentType() {
        switch type {
        case .count:
            unit = "次"
        case .streak:
            unit = "天"
        case .amount:
            unit = "元"
        case .duration:
            if !unitOptions.contains(unit) {
                unit = "小时"
            }
        case .checkpoint:
            unit = ""
        case .custom:
            let canonicalUnits = ["次", "天", "小时", "分钟", "元"]
            if canonicalUnits.contains(unit) {
                unit = ""
            }
        }
    }
}
