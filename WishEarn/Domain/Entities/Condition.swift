import Foundation

struct Condition: Identifiable, Equatable, Sendable {
    private(set) var id: UUID
    private(set) var wishID: UUID
    private(set) var title: String
    private(set) var description: String?
    private(set) var type: ConditionType
    private(set) var targetValue: Decimal
    private(set) var unit: String?
    private(set) var amountDirection: AmountDirection?
    private(set) var isRequired: Bool
    private(set) var sortOrder: Int
    private(set) var createdAt: Date

    init(
        id: UUID = UUID(),
        wishID: UUID,
        title: String,
        description: String? = nil,
        type: ConditionType,
        targetValue: Decimal,
        unit: String? = nil,
        amountDirection: AmountDirection? = nil,
        isRequired: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw DomainError.invalidInput("条件名称不能为空。")
        }

        guard targetValue > 0 else {
            throw DomainError.invalidInput("条件目标值必须大于 0。")
        }

        if type.requiresAmountDirection {
            guard amountDirection != nil else {
                throw DomainError.invalidInput("金额条件必须指定金额方向。")
            }
        } else {
            guard amountDirection == nil else {
                throw DomainError.invalidInput("只有金额条件可以指定金额方向。")
            }
        }

        guard sortOrder >= 0 else {
            throw DomainError.invalidInput("条件排序值不能为负数。")
        }

        self.id = id
        self.wishID = wishID
        self.title = trimmedTitle
        self.description = description
        self.type = type
        self.targetValue = targetValue
        self.unit = unit
        self.amountDirection = amountDirection
        self.isRequired = isRequired
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }

    mutating func updateSortOrder(_ sortOrder: Int) throws {
        guard sortOrder >= 0 else {
            throw DomainError.invalidInput("条件排序值不能为负数。")
        }
        self.sortOrder = sortOrder
    }
}
