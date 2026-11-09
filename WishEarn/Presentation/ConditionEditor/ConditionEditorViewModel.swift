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

    var isEditing: Bool {
        existingCondition != nil
    }

    var showsTargetField: Bool {
        type != .checkpoint
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

        normalizeUnitForCurrentType()
    }

    func onTypeChanged() {
        normalizeUnitForCurrentType()

        if type == .checkpoint {
            targetText = "1"
        }
    }

    func save() {
        guard !isSaving else { return }

        error = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            error = .domain(.invalidInput("请输入条件名称。"))
            return
        }

        let targetValue: Decimal
        if type == .checkpoint {
            targetValue = 1
        } else {
            let trimmedTarget = targetText
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let parsed = Decimal(string: trimmedTarget, locale: Locale(identifier: "en_US_POSIX")),
                  parsed > 0 else {
                error = .domain(.invalidInput("目标值必须大于 0。"))
                return
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
