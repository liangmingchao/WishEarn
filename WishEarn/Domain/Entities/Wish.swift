import Foundation

struct Wish: Identifiable, Equatable, Sendable {
    private(set) var id: UUID
    private(set) var title: String
    private(set) var description: String?
    private(set) var imagePath: String?
    private(set) var targetPrice: Decimal?
    private(set) var currencyCode: String
    private(set) var targetDate: Date?
    private(set) var status: WishStatus
    private(set) var createdAt: Date
    private(set) var updatedAt: Date
    private(set) var unlockedAt: Date?
    private(set) var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        imagePath: String? = nil,
        targetPrice: Decimal? = nil,
        currencyCode: String = "CNY",
        targetDate: Date? = nil,
        status: WishStatus = .active,
        createdAt: Date,
        updatedAt: Date,
        unlockedAt: Date? = nil,
        completedAt: Date? = nil
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw DomainError.invalidInput("心愿名称不能为空。")
        }

        let trimmedCurrency = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCurrency.isEmpty else {
            throw DomainError.invalidInput("货币代码不能为空。")
        }

        if let targetPrice, targetPrice < 0 {
            throw DomainError.invalidInput("参考价格不能为负数。")
        }

        self.id = id
        self.title = trimmedTitle
        self.description = description
        self.imagePath = imagePath
        self.targetPrice = targetPrice
        self.currencyCode = trimmedCurrency
        self.targetDate = targetDate
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.unlockedAt = unlockedAt
        self.completedAt = completedAt
    }

    mutating func updateDetails(
        title: String,
        description: String?,
        imagePath: String?,
        targetPrice: Decimal?,
        currencyCode: String,
        targetDate: Date?,
        now: Date
    ) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw DomainError.invalidInput("心愿名称不能为空。")
        }

        let trimmedCurrency = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCurrency.isEmpty else {
            throw DomainError.invalidInput("货币代码不能为空。")
        }

        if let targetPrice, targetPrice < 0 {
            throw DomainError.invalidInput("参考价格不能为负数。")
        }

        self.title = trimmedTitle
        self.description = description
        self.imagePath = imagePath
        self.targetPrice = targetPrice
        self.currencyCode = trimmedCurrency
        self.targetDate = targetDate
        self.updatedAt = now
    }
}
