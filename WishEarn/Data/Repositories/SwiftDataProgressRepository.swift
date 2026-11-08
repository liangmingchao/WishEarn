import Foundation
import SwiftData

@MainActor
final class SwiftDataProgressRepository: ProgressRepository {
    private let store: SwiftDataStore

    init(store: SwiftDataStore) {
        self.store = store
    }

    func fetchRecords(conditionID: UUID) throws -> [ProgressRecord] {
        do {
            let descriptor = FetchDescriptor<ProgressRecordEntity>(
                predicate: #Predicate { $0.conditionID == conditionID },
                sortBy: [SortDescriptor(\ProgressRecordEntity.recordedAt, order: .reverse)]
            )
            return try store.context.fetch(descriptor).map(ProgressRecordMapper.toDomain)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func save(_ record: ProgressRecord) throws {
        do {
            let id = record.id
            let descriptor = FetchDescriptor<ProgressRecordEntity>(
                predicate: #Predicate { $0.id == id }
            )
            if let entity = try store.context.fetch(descriptor).first {
                ProgressRecordMapper.update(entity, from: record)
            } else {
                store.context.insert(ProgressRecordMapper.makeEntity(from: record))
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
                let descriptor = FetchDescriptor<ProgressRecordEntity>(
                    predicate: #Predicate { $0.id == id }
                )
                guard let record = try store.context.fetch(descriptor).first else {
                    throw PersistenceError.notFound
                }
                store.context.delete(record)
            }
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }

    func deleteAll(conditionID: UUID) throws {
        do {
            try store.transaction {
                let descriptor = FetchDescriptor<ProgressRecordEntity>(
                    predicate: #Predicate { $0.conditionID == conditionID }
                )
                for record in try store.context.fetch(descriptor) {
                    store.context.delete(record)
                }
            }
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.deleteFailed(error.localizedDescription)
        }
    }
}
