import Foundation
import SwiftData

@Model
final class UnlockEventEntity {
    @Attribute(.unique) var id: UUID
    var wishID: UUID
    var unlockedAt: Date
    var conditionSnapshot: String
    var createdAt: Date

    init(
        id: UUID,
        wishID: UUID,
        unlockedAt: Date,
        conditionSnapshot: String,
        createdAt: Date
    ) {
        self.id = id
        self.wishID = wishID
        self.unlockedAt = unlockedAt
        self.conditionSnapshot = conditionSnapshot
        self.createdAt = createdAt
    }
}
