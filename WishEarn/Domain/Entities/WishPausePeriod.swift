import Foundation

struct WishPausePeriod: Identifiable, Equatable, Sendable {
    let id: UUID
    let wishID: UUID
    let startedAt: Date
    let endedAt: Date?

    init(
        id: UUID = UUID(),
        wishID: UUID,
        startedAt: Date,
        endedAt: Date? = nil
    ) throws {
        if let endedAt, endedAt < startedAt {
            throw DomainError.invalidInput("暂停结束时间不能早于开始时间。")
        }

        self.id = id
        self.wishID = wishID
        self.startedAt = startedAt
        self.endedAt = endedAt
    }

    var isOpen: Bool {
        endedAt == nil
    }
}
