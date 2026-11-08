import Foundation
import SwiftData

@Model
final class ConditionEntity {
    @Attribute(.unique) var id: UUID
    var wishID: UUID
    var title: String
    var conditionDescription: String?
    var typeRaw: String
    var targetValue: Decimal
    var unit: String?
    var amountDirectionRaw: String?
    var isRequired: Bool
    var sortOrder: Int
    var createdAt: Date

    init(
        id: UUID,
        wishID: UUID,
        title: String,
        conditionDescription: String?,
        typeRaw: String,
        targetValue: Decimal,
        unit: String?,
        amountDirectionRaw: String?,
        isRequired: Bool,
        sortOrder: Int,
        createdAt: Date
    ) {
        self.id = id
        self.wishID = wishID
        self.title = title
        self.conditionDescription = conditionDescription
        self.typeRaw = typeRaw
        self.targetValue = targetValue
        self.unit = unit
        self.amountDirectionRaw = amountDirectionRaw
        self.isRequired = isRequired
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}
