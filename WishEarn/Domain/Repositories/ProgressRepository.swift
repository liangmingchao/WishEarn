import Foundation

@MainActor
protocol ProgressRepository {
    func fetchRecords(conditionID: UUID) throws -> [ProgressRecord]
    func save(_ record: ProgressRecord) throws
    func delete(id: UUID) throws
    func deleteAll(conditionID: UUID) throws
}
