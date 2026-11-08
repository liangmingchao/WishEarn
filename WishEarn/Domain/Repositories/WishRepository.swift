import Foundation

@MainActor
protocol WishRepository {
    func fetch(id: UUID) throws -> Wish?
    func fetchAll() throws -> [Wish]
    func fetch(status: WishStatus) throws -> [Wish]
    func save(_ wish: Wish) throws
    func delete(id: UUID) throws
}
