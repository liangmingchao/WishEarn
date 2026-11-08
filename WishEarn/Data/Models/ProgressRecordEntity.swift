import Foundation
import SwiftData

@Model
final class ProgressRecordEntity {
    @Attribute(.unique) var id: UUID
    var conditionID: UUID
    var value: Decimal
    var note: String?
    var recordedAt: Date
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        conditionID: UUID,
        value: Decimal,
        note: String?,
        recordedAt: Date,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.conditionID = conditionID
        self.value = value
        self.note = note
        self.recordedAt = recordedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
