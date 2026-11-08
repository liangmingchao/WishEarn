import Foundation

struct ProgressRecord: Identifiable, Equatable, Sendable {
    private(set) var id: UUID
    private(set) var conditionID: UUID
    private(set) var value: Decimal
    private(set) var note: String?
    private(set) var recordedAt: Date
    private(set) var createdAt: Date
    private(set) var updatedAt: Date

    init(
        id: UUID = UUID(),
        conditionID: UUID,
        value: Decimal,
        note: String? = nil,
        recordedAt: Date,
        createdAt: Date,
        updatedAt: Date
    ) throws {
        guard value >= 0 else {
            throw DomainError.invalidInput("记录值不能为负数。")
        }

        self.id = id
        self.conditionID = conditionID
        self.value = value
        self.note = note
        self.recordedAt = recordedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    mutating func update(
        value: Decimal,
        note: String?,
        recordedAt: Date,
        now: Date
    ) throws {
        guard value >= 0 else {
            throw DomainError.invalidInput("记录值不能为负数。")
        }

        self.value = value
        self.note = note
        self.recordedAt = recordedAt
        self.updatedAt = now
    }
}
