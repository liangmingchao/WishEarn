import Foundation

struct UnlockEvent: Identifiable, Equatable, Sendable {
    let id: UUID
    let wishID: UUID
    let unlockedAt: Date
    let conditionSnapshot: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        wishID: UUID,
        unlockedAt: Date,
        conditionSnapshot: String,
        createdAt: Date
    ) throws {
        let trimmedSnapshot = conditionSnapshot.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSnapshot.isEmpty else {
            throw DomainError.invalidInput("解锁时的条件快照不能为空。")
        }

        self.id = id
        self.wishID = wishID
        self.unlockedAt = unlockedAt
        self.conditionSnapshot = trimmedSnapshot
        self.createdAt = createdAt
    }
}
