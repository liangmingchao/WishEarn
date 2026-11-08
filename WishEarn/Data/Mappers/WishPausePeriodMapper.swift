import Foundation

enum WishPausePeriodMapper {
    static func toDomain(_ entity: WishPausePeriodEntity) throws -> WishPausePeriod {
        try WishPausePeriod(
            id: entity.id,
            wishID: entity.wishID,
            startedAt: entity.startedAt,
            endedAt: entity.endedAt
        )
    }

    static func makeEntity(from period: WishPausePeriod) -> WishPausePeriodEntity {
        WishPausePeriodEntity(
            id: period.id,
            wishID: period.wishID,
            startedAt: period.startedAt,
            endedAt: period.endedAt
        )
    }

    static func update(_ entity: WishPausePeriodEntity, from period: WishPausePeriod) {
        entity.wishID = period.wishID
        entity.startedAt = period.startedAt
        entity.endedAt = period.endedAt
    }
}
