import Foundation

enum ConditionMapper {
    static func toDomain(_ entity: ConditionEntity) throws -> Condition {
        guard let type = ConditionType(rawValue: entity.typeRaw) else {
            throw PersistenceError.fetchFailed("未知条件类型：\(entity.typeRaw)")
        }

        let amountDirection: AmountDirection?
        if let raw = entity.amountDirectionRaw {
            guard let direction = AmountDirection(rawValue: raw) else {
                throw PersistenceError.fetchFailed("未知金额方向：\(raw)")
            }
            amountDirection = direction
        } else {
            amountDirection = nil
        }

        return try Condition(
            id: entity.id,
            wishID: entity.wishID,
            title: entity.title,
            description: entity.conditionDescription,
            type: type,
            targetValue: entity.targetValue,
            unit: entity.unit,
            amountDirection: amountDirection,
            isRequired: entity.isRequired,
            sortOrder: entity.sortOrder,
            createdAt: entity.createdAt
        )
    }

    static func makeEntity(from condition: Condition) -> ConditionEntity {
        ConditionEntity(
            id: condition.id,
            wishID: condition.wishID,
            title: condition.title,
            conditionDescription: condition.description,
            typeRaw: condition.type.rawValue,
            targetValue: condition.targetValue,
            unit: condition.unit,
            amountDirectionRaw: condition.amountDirection?.rawValue,
            isRequired: condition.isRequired,
            sortOrder: condition.sortOrder,
            createdAt: condition.createdAt
        )
    }

    static func update(_ entity: ConditionEntity, from condition: Condition) {
        entity.wishID = condition.wishID
        entity.title = condition.title
        entity.conditionDescription = condition.description
        entity.typeRaw = condition.type.rawValue
        entity.targetValue = condition.targetValue
        entity.unit = condition.unit
        entity.amountDirectionRaw = condition.amountDirection?.rawValue
        entity.isRequired = condition.isRequired
        entity.sortOrder = condition.sortOrder
        entity.createdAt = condition.createdAt
    }
}
