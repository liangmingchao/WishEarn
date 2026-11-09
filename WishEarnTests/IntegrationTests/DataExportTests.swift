import XCTest
@testable import WishEarn

@MainActor
final class DataExportTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private func makeSUT() throws -> (DataExportService, SwiftDataStore) {
        let container = try ModelContainerFactory.make(inMemory: true)
        let store = SwiftDataStore(container: container)
        let service = DataExportService(
            wishRepository: SwiftDataWishRepository(store: store),
            conditionRepository: SwiftDataConditionRepository(store: store),
            progressRepository: SwiftDataProgressRepository(store: store),
            unlockEventRepository: SwiftDataUnlockEventRepository(store: store),
            pausePeriodRepository: SwiftDataWishPausePeriodRepository(store: store),
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        return (service, store)
    }

    private func decode(_ data: Data) throws -> WishEarnExport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(WishEarnExport.self, from: data)
    }

    func testExportContainsAllEntities() throws {
        let (service, store) = try makeSUT()
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/wish.jpg",
            targetPrice: 1099,
            status: .unlocked,
            createdAt: now,
            updatedAt: now,
            unlockedAt: now
        )
        let condition = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 10,
            unit: "次",
            createdAt: now
        )
        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 5,
            note: "跑步",
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: now,
            conditionSnapshot: #"[{"title":"健身"}]"#,
            createdAt: now
        )
        let period = try WishPausePeriod(
            wishID: wish.id,
            startedAt: now,
            endedAt: now.addingTimeInterval(3600)
        )

        try SwiftDataWishRepository(store: store).save(wish)
        try SwiftDataConditionRepository(store: store).save(condition)
        try SwiftDataProgressRepository(store: store).save(record)
        try SwiftDataUnlockEventRepository(store: store).save(event)
        try SwiftDataWishPausePeriodRepository(store: store).save(period)

        let data = try service.exportData()
        let export = try decode(data)

        XCTAssertEqual(export.schemaVersion, 1)
        XCTAssertEqual(export.exportedAt, now)
        XCTAssertEqual(export.wishes.count, 1)
        XCTAssertEqual(export.conditions.count, 1)
        XCTAssertEqual(export.progressRecords.count, 1)
        XCTAssertEqual(export.unlockEvents.count, 1)
        XCTAssertEqual(export.pausePeriods.count, 1)

        let exportedWish = try XCTUnwrap(export.wishes.first)
        XCTAssertEqual(exportedWish.id, wish.id)
        XCTAssertEqual(exportedWish.title, "Kindle")
        XCTAssertEqual(exportedWish.imagePath, "WishImages/wish.jpg")
        XCTAssertEqual(exportedWish.targetPrice, 1099)
        XCTAssertEqual(exportedWish.status, "unlocked")
        XCTAssertEqual(exportedWish.unlockedAt, now)

        let exportedCondition = try XCTUnwrap(export.conditions.first)
        XCTAssertEqual(exportedCondition.type, "count")
        XCTAssertEqual(exportedCondition.targetValue, 10)
        XCTAssertEqual(exportedCondition.unit, "次")

        let exportedRecord = try XCTUnwrap(export.progressRecords.first)
        XCTAssertEqual(exportedRecord.value, 5)
        XCTAssertEqual(exportedRecord.note, "跑步")

        XCTAssertEqual(export.unlockEvents.first?.conditionSnapshot, #"[{"title":"健身"}]"#)
        XCTAssertNotNil(export.pausePeriods.first?.endedAt)
    }

    func testEmptyExport() throws {
        let (service, _) = try makeSUT()

        let export = try decode(service.exportData())

        XCTAssertEqual(export.schemaVersion, 1)
        XCTAssertEqual(export.exportedAt, now)
        XCTAssertTrue(export.wishes.isEmpty)
        XCTAssertTrue(export.conditions.isEmpty)
        XCTAssertTrue(export.progressRecords.isEmpty)
        XCTAssertTrue(export.unlockEvents.isEmpty)
        XCTAssertTrue(export.pausePeriods.isEmpty)
    }
}
