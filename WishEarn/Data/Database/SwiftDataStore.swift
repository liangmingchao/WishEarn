import SwiftData

@MainActor
final class SwiftDataStore {
    let container: ModelContainer
    let context: ModelContext

    init(container: ModelContainer) {
        self.container = container
        self.context = ModelContext(container)
        self.context.autosaveEnabled = false
    }

    func save() throws {
        do {
            try context.save()
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    func transaction(_ work: () throws -> Void) throws {
        do {
            try context.transaction {
                try work()
            }
        } catch let error as PersistenceError {
            throw error
        } catch {
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }
}
