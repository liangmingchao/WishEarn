import Foundation
import SwiftData

@MainActor
final class SwiftDataWishRepository: WishRepository {
    private let store: SwiftDataStore

    init(store: SwiftDataStore) {
        self.store = store
    }

    func fetch(id: UUID) throws -> Wish? {
        do {
            let descriptor = FetchDescriptor<WishEntity>(
                predicate: #Predicate { $0.id == id }
            )
            guard let entity = try store.context.fetch(descriptor).first else {
                return nil
            }
            return try WishMapper.toDomain(entity)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func fetchAll() throws -> [Wish] {
        do {
            let descriptor = FetchDescriptor<WishEntity>(
                sortBy: [SortDescriptor(\WishEntity.createdAt, order: .reverse)]
            )
            return try store.context.fetch(descriptor).map(WishMapper.toDomain)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func fetch(status: WishStatus) throws -> [Wish] {
        do {
            let raw = status.rawValue
            let descriptor = FetchDescriptor<WishEntity>(
                predicate: #Predicate { $0.statusRaw == raw },
                sortBy: [SortDescriptor(\WishEntity.createdAt, order: .reverse)]
            )
            return try store.context.fetch(descriptor).map(WishMapper.toDomain)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func save(_ wish: Wish) throws {
        do {
            let id = wish.id
            let descriptor = FetchDescriptor<WishEntity>(
                predicate: #Predicate { $0.id == id }
            )
            if let entity = try store.context.fetch(descriptor).first {
                WishMapper.update(entity, from: wish)
            } else {
                store.context.insert(WishMapper.makeEntity(from: wish))
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
                let wishDescriptor = FetchDescriptor<WishEntity>(
                    predicate: #Predicate { $0.id == id }
                )
                guard let wish = try store.context.fetch(wishDescriptor).first else {
                    throw PersistenceError.notFound
                }

                let conditionDescriptor = FetchDescriptor<ConditionEntity>(
                    predicate: #Predicate { $0.wishID == id }
                )
                let conditions = try store.context.fetch(conditionDescriptor)
                for condition in conditions {
                    let conditionID = condition.id
                    let recordDescriptor = FetchDescriptor<ProgressRecordEntity>(
                        predicate: #Predicate { $0.conditionID == conditionID }
                    )
                    for record in try store.context.fetch(recordDescriptor) {
                        store.context.delete(record)
                    }
                    store.context.delete(condition)
                }

                let eventDescriptor = FetchDescriptor<UnlockEventEntity>(
                    predicate: #Predicate { $0.wishID == id }
                )
                for event in try store.context.fetch(eventDescriptor) {
                    store.context.delete(event)
                }

                let pauseDescriptor = FetchDescriptor<WishPausePeriodEntity>(
                    predicate: #Predicate { $0.wishID == id }
                )
                for period in try store.context.fetch(pauseDescriptor) {
                    store.context.delete(period)
                }

                store.context.delete(wish)
            }
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }
}
