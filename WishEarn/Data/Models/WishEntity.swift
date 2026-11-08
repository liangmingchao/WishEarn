import Foundation
import SwiftData

@Model
final class WishEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var wishDescription: String?
    var imagePath: String?
    var targetPrice: Decimal?
    var currencyCode: String
    var targetDate: Date?
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date
    var unlockedAt: Date?
    var completedAt: Date?

    init(
        id: UUID,
        title: String,
        wishDescription: String?,
        imagePath: String?,
        targetPrice: Decimal?,
        currencyCode: String,
        targetDate: Date?,
        statusRaw: String,
        createdAt: Date,
        updatedAt: Date,
        unlockedAt: Date?,
        completedAt: Date?
    ) {
        self.id = id
        self.title = title
        self.wishDescription = wishDescription
        self.imagePath = imagePath
        self.targetPrice = targetPrice
        self.currencyCode = currencyCode
        self.targetDate = targetDate
        self.statusRaw = statusRaw
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.unlockedAt = unlockedAt
        self.completedAt = completedAt
    }
}
