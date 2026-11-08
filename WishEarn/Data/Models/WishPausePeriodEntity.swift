import Foundation
import SwiftData

@Model
final class WishPausePeriodEntity {
    @Attribute(.unique) var id: UUID
    var wishID: UUID
    var startedAt: Date
    var endedAt: Date?

    init(
        id: UUID,
        wishID: UUID,
        startedAt: Date,
        endedAt: Date?
    ) {
        self.id = id
        self.wishID = wishID
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}
