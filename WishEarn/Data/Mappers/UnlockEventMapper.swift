import Foundation

enum UnlockEventMapper {
    static func toDomain(_ entity: UnlockEventEntity) throws -> UnlockEvent {
        try UnlockEvent(
            id: entity.id,
            wishID: entity.wishID,
            unlockedAt: entity.unlockedAt,
            conditionSnapshot: entity.conditionSnapshot,
            createdAt: entity.createdAt
        )
    }

    static func makeEntity(from event: UnlockEvent) -> UnlockEventEntity {
        UnlockEventEntity(
            id: event.id,
            wishID: event.wishID,
            unlockedAt: event.unlockedAt,
            conditionSnapshot: event.conditionSnapshot,
            createdAt: event.createdAt
        )
    }
}
