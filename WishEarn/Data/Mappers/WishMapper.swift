import Foundation

enum WishMapper {
    static func toDomain(_ entity: WishEntity) throws -> Wish {
        guard let status = WishStatus(rawValue: entity.statusRaw) else {
            throw PersistenceError.fetchFailed("未知心愿状态：\(entity.statusRaw)")
        }

        return try Wish(
            id: entity.id,
            title: entity.title,
            description: entity.wishDescription,
            imagePath: entity.imagePath,
            targetPrice: entity.targetPrice,
            currencyCode: entity.currencyCode,
            targetDate: entity.targetDate,
            status: status,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            unlockedAt: entity.unlockedAt,
            completedAt: entity.completedAt
        )
    }

    static func makeEntity(from wish: Wish) -> WishEntity {
        WishEntity(
            id: wish.id,
            title: wish.title,
            wishDescription: wish.description,
            imagePath: wish.imagePath,
            targetPrice: wish.targetPrice,
            currencyCode: wish.currencyCode,
            targetDate: wish.targetDate,
            statusRaw: wish.status.rawValue,
            createdAt: wish.createdAt,
            updatedAt: wish.updatedAt,
            unlockedAt: wish.unlockedAt,
            completedAt: wish.completedAt
        )
    }

    static func update(_ entity: WishEntity, from wish: Wish) {
        entity.title = wish.title
        entity.wishDescription = wish.description
        entity.imagePath = wish.imagePath
        entity.targetPrice = wish.targetPrice
        entity.currencyCode = wish.currencyCode
        entity.targetDate = wish.targetDate
        entity.statusRaw = wish.status.rawValue
        entity.createdAt = wish.createdAt
        entity.updatedAt = wish.updatedAt
        entity.unlockedAt = wish.unlockedAt
        entity.completedAt = wish.completedAt
    }
}
