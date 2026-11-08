import Foundation
import SwiftData

@MainActor
final class SwiftDataWishPausePeriodRepository: WishPausePeriodRepository {
    private let store: SwiftDataStore

    init(store: SwiftDataStore) {
        self.store = store
    }

    func fetchPeriods(wishID: UUID) throws -> [WishPausePeriod] {
        do {
            let descriptor = FetchDescriptor<WishPausePeriodEntity>(
                predicate: #Predicate { $0.wishID == wishID },
                sortBy: [SortDescriptor(\WishPausePeriodEntity.startedAt, order: .forward)]
            )
            return try store.context.fetch(descriptor).map(WishPausePeriodMapper.toDomain)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func save(_ period: WishPausePeriod) throws {
        do {
            let id = period.id
            let descriptor = FetchDescriptor<WishPausePeriodEntity>(
                predicate: #Predicate { $0.id == id }
            )
            if let entity = try store.context.fetch(descriptor).first {
                WishPausePeriodMapper.update(entity, from: period)
            } else {
                store.context.insert(WishPausePeriodMapper.makeEntity(from: period))
            }
            try store.save()
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    func delete(id: UUID) throws {
        do {
            try store.transaction {
                let descriptor = FetchDescriptor<WishPausePeriodEntity>(
                    predicate: #Predicate { $0.id == id }
                )
                guard let period = try store.context.fetch(descriptor).first else {
                    throw PersistenceError.notFound
                }
                store.context.delete(period)
            }
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }
}
