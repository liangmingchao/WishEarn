import Foundation

@MainActor
protocol ConditionRepository {
    func fetch(id: UUID) throws -> Condition?
    func fetchConditions(wishID: UUID) throws -> [Condition]
    func save(_ condition: Condition) throws
    func delete(id: UUID) throws
}
