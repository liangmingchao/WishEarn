import Foundation
import SwiftData

@MainActor
final class SwiftDataUnlockEventRepository: UnlockEventRepository {
    private let store: SwiftDataStore

    init(store: SwiftDataStore) {
        self.store = store
    }

    func fetchEvents(wishID: UUID) throws -> [UnlockEvent] {
        do {
            let descriptor = FetchDescriptor<UnlockEventEntity>(
                predicate: #Predicate { $0.wishID == wishID },
                sortBy: [SortDescriptor(\UnlockEventEntity.unlockedAt, order: .reverse)]
            )
            return try store.context.fetch(descriptor).map(UnlockEventMapper.toDomain)
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func hasEvent(wishID: UUID) throws -> Bool {
        do {
            var descriptor = FetchDescriptor<UnlockEventEntity>(
                predicate: #Predicate { $0.wishID == wishID }
            )
            descriptor.fetchLimit = 1
            return try !store.context.fetch(descriptor).isEmpty
        } catch {
            throw PersistenceError.fetchFailed(error.localizedDescription)
        }
    }

    func save(_ event: UnlockEvent) throws {
        do {
            let id = event.id
            let descriptor = FetchDescriptor<UnlockEventEntity>(
                predicate: #Predicate { $0.id == id }
            )
            guard try store.context.fetch(descriptor).isEmpty else {
                return
            }
            store.context.insert(UnlockEventMapper.makeEntity(from: event))
            try store.save()
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }
}
