import Foundation

@MainActor
protocol UnlockEventRepository {
    func fetchEvents(wishID: UUID) throws -> [UnlockEvent]
    func hasEvent(wishID: UUID) throws -> Bool
    func save(_ event: UnlockEvent) throws
}
