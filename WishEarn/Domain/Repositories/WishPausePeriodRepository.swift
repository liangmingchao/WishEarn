import Foundation

@MainActor
protocol WishPausePeriodRepository {
    func fetchPeriods(wishID: UUID) throws -> [WishPausePeriod]
    func save(_ period: WishPausePeriod) throws
    func delete(id: UUID) throws
}
