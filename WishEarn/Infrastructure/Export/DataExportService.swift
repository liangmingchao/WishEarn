import Foundation

struct WishEarnExport: Codable {
    let schemaVersion: Int
    let exportedAt: Date
    let wishes: [WishExport]
    let conditions: [ConditionExport]
    let progressRecords: [ProgressRecordExport]
    let unlockEvents: [UnlockEventExport]
    let pausePeriods: [PausePeriodExport]
}

struct WishExport: Codable {
    let id: UUID
    let title: String
    let description: String?
    let imagePath: String?
    let targetPrice: Decimal?
    let currencyCode: String
    let targetDate: Date?
    let status: String
    let createdAt: Date
    let updatedAt: Date
    let unlockedAt: Date?
    let completedAt: Date?
}

struct ConditionExport: Codable {
    let id: UUID
    let wishID: UUID
    let title: String
    let description: String?
    let type: String
    let targetValue: Decimal
    let unit: String?
    let amountDirection: String?
    let isRequired: Bool
    let sortOrder: Int
    let createdAt: Date
}

struct ProgressRecordExport: Codable {
    let id: UUID
    let conditionID: UUID
    let value: Decimal
    let note: String?
    let recordedAt: Date
    let createdAt: Date
    let updatedAt: Date
}

struct UnlockEventExport: Codable {
    let id: UUID
    let wishID: UUID
    let unlockedAt: Date
    let conditionSnapshot: String
    let createdAt: Date
}

struct PausePeriodExport: Codable {
    let id: UUID
    let wishID: UUID
    let startedAt: Date
    let endedAt: Date?
}

@MainActor
final class DataExportService {
    private let wishRepository: WishRepository
    private let conditionRepository: ConditionRepository
    private let progressRepository: ProgressRepository
    private let unlockEventRepository: UnlockEventRepository
    private let pausePeriodRepository: WishPausePeriodRepository
    private let clock: ClockProviding

    init(
        wishRepository: WishRepository,
        conditionRepository: ConditionRepository,
        progressRepository: ProgressRepository,
        unlockEventRepository: UnlockEventRepository,
        pausePeriodRepository: WishPausePeriodRepository,
        clock: ClockProviding
    ) {
        self.wishRepository = wishRepository
        self.conditionRepository = conditionRepository
        self.progressRepository = progressRepository
        self.unlockEventRepository = unlockEventRepository
        self.pausePeriodRepository = pausePeriodRepository
        self.clock = clock
    }

    func exportData() throws -> Data {
        let wishes = try wishRepository.fetchAll()

        var conditions: [Condition] = []
        var records: [ProgressRecord] = []
        var events: [UnlockEvent] = []
        var periods: [WishPausePeriod] = []

        for wish in wishes {
            let wishConditions = try conditionRepository.fetchConditions(wishID: wish.id)
            conditions.append(contentsOf: wishConditions)

            for condition in wishConditions {
                records.append(
                    contentsOf: try progressRepository.fetchRecords(conditionID: condition.id)
                )
            }

            events.append(
                contentsOf: try unlockEventRepository.fetchEvents(wishID: wish.id)
            )
            periods.append(
                contentsOf: try pausePeriodRepository.fetchPeriods(wishID: wish.id)
            )
        }

        let export = WishEarnExport(
            schemaVersion: 1,
            exportedAt: clock.now,
            wishes: wishes.map(Self.map(wish:)),
            conditions: conditions.map(Self.map(condition:)),
            progressRecords: records.map(Self.map(record:)),
            unlockEvents: events.map(Self.map(event:)),
            pausePeriods: periods.map(Self.map(period:))
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(export)
    }

    private static func map(wish: Wish) -> WishExport {
        WishExport(
            id: wish.id,
            title: wish.title,
            description: wish.description,
            imagePath: wish.imagePath,
            targetPrice: wish.targetPrice,
            currencyCode: wish.currencyCode,
            targetDate: wish.targetDate,
            status: wish.status.rawValue,
            createdAt: wish.createdAt,
            updatedAt: wish.updatedAt,
            unlockedAt: wish.unlockedAt,
            completedAt: wish.completedAt
        )
    }

    private static func map(condition: Condition) -> ConditionExport {
        ConditionExport(
            id: condition.id,
            wishID: condition.wishID,
            title: condition.title,
            description: condition.description,
            type: condition.type.rawValue,
            targetValue: condition.targetValue,
            unit: condition.unit,
            amountDirection: condition.amountDirection?.rawValue,
            isRequired: condition.isRequired,
            sortOrder: condition.sortOrder,
            createdAt: condition.createdAt
        )
    }

    private static func map(record: ProgressRecord) -> ProgressRecordExport {
        ProgressRecordExport(
            id: record.id,
            conditionID: record.conditionID,
            value: record.value,
            note: record.note,
            recordedAt: record.recordedAt,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }

    private static func map(event: UnlockEvent) -> UnlockEventExport {
        UnlockEventExport(
            id: event.id,
            wishID: event.wishID,
            unlockedAt: event.unlockedAt,
            conditionSnapshot: event.conditionSnapshot,
            createdAt: event.createdAt
        )
    }

    private static func map(period: WishPausePeriod) -> PausePeriodExport {
        PausePeriodExport(
            id: period.id,
            wishID: period.wishID,
            startedAt: period.startedAt,
            endedAt: period.endedAt
        )
    }
}
