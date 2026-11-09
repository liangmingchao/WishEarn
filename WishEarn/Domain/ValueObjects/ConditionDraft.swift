import Foundation

struct ConditionDraft: Equatable {
    var wishID: UUID
    var title: String
    var description: String?
    var type: ConditionType
    var targetValue: Decimal
    var unit: String?
    var amountDirection: AmountDirection?
    var isRequired: Bool
    var sortOrder: Int

    func validate() throws {
        try ConditionTargetValidator.validate(
            type: type,
            targetValue: targetValue
        )
    }
}
