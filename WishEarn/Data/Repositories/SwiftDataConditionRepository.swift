import Foundation
import SwiftData

@MainActor
final class SwiftDataConditionRepository: ConditionRepository {
    private let store: SwiftDataStore

    init(store: SwiftDataStore) {
        self.store = store
    }

    func fetch(id: UUID) throws -> Condition? {
        do {
            let descriptor = FetchDescriptor<ConditionEntity>(
                predicate: #Predicate { $0.id == id }
            )
            guard let entity = try store.context.fetch(descriptor).first else {
                return nil
            }
            return try ConditionMapper.toDomain(entity)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func fetchConditions(wishID: UUID) throws -> [Condition] {
        do {
            let descriptor = FetchDescriptor<ConditionEntity>(
                predicate: #Predicate { $0.wishID == wishID },
                sortBy: [SortDescriptor(\ConditionEntity.sortOrder, order: .forward)]
            )
            return try store.context.fetch(descriptor).map(ConditionMapper.toDomain)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func save(_ condition: Condition) throws {
        do {
            let id = condition.id
            let descriptor = FetchDescriptor<ConditionEntity>(
                predicate: #Predicate { $0.id == id }
            )
            if let entity = try store.context.fetch(descriptor).first {
                ConditionMapper.update(entity, from: condition)
            } else {
                store.context.insert(ConditionMapper.makeEntity(from: condition))
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
                let descriptor = FetchDescriptor<ConditionEntity>(
                    predicate: #Predicate { $0.id == id }
                )
                guard let condition = try store.context.fetch(descriptor).first else {
                    throw PersistenceError.notFound
                }

                let recordDescriptor = FetchDescriptor<ProgressRecordEntity>(
                    predicate: #Predicate { $0.conditionID == id }
                )
                for record in try store.context.fetch(recordDescriptor) {
                    store.context.delete(record)
                }
                store.context.delete(condition)
            }
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }
}
