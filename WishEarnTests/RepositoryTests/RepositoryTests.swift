import XCTest
@testable import WishEarn

@MainActor
final class RepositoryTests: XCTestCase {
    private struct SUT {
        let wishRepository: SwiftDataWishRepository
        let conditionRepository: SwiftDataConditionRepository
        let progressRepository: SwiftDataProgressRepository
        let unlockEventRepository: SwiftDataUnlockEventRepository
        let pausePeriodRepository: SwiftDataWishPausePeriodRepository
    }

    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let later = TestDates.make(year: 2026, month: 11, day: 9)

    private func makeSUT() throws -> SUT {
        let container = try ModelContainerFactory.make(inMemory: true)
        let store = SwiftDataStore(container: container)
        return SUT(
            wishRepository: SwiftDataWishRepository(store: store),
            conditionRepository: SwiftDataConditionRepository(store: store),
            progressRepository: SwiftDataProgressRepository(store: store),
            unlockEventRepository: SwiftDataUnlockEventRepository(store: store),
            pausePeriodRepository: SwiftDataWishPausePeriodRepository(store: store)
        )
    }

    private func makeWish() throws -> Wish {
        try Wish(title: "Kindle", targetPrice: 1099, createdAt: now, updatedAt: now)
    }

    func testWishCRUD() throws {
        let sut = try makeSUT()
        let wish = try makeWish()

        try sut.wishRepository.save(wish)

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id), wish)
        XCTAssertEqual(try sut.wishRepository.fetchAll(), [wish])
        XCTAssertEqual(try sut.wishRepository.fetch(status: .active), [wish])
        XCTAssertTrue(try sut.wishRepository.fetch(status: .paused).isEmpty)

        var updated = wish
        try updated.updateDetails(
            title: "Kindle Paperwhite",
            description: "阅读目标",
            imagePath: nil,
            targetPrice: 1099,
            currencyCode: "CNY",
            targetDate: nil,
            now: later
        )
        try sut.wishRepository.save(updated)

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.title, "Kindle Paperwhite")

        try sut.wishRepository.delete(id: wish.id)

        XCTAssertNil(try sut.wishRepository.fetch(id: wish.id))
        XCTAssertTrue(try sut.wishRepository.fetchAll().isEmpty)
    }

    func testConditionAndProgressCRUD() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次",
            sortOrder: 0,
            createdAt: now
        )
        try sut.conditionRepository.save(condition)

        XCTAssertEqual(try sut.conditionRepository.fetch(id: condition.id), condition)
        XCTAssertEqual(try sut.conditionRepository.fetchConditions(wishID: wish.id), [condition])

        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 5,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        try sut.progressRepository.save(record)

        XCTAssertEqual(try sut.progressRepository.fetchRecords(conditionID: condition.id), [record])

        var updatedRecord = record
        try updatedRecord.update(value: 8, note: "加练", recordedAt: now, now: later)
        try sut.progressRepository.save(updatedRecord)

        XCTAssertEqual(try sut.progressRepository.fetchRecords(conditionID: condition.id).first?.value, 8)

        try sut.progressRepository.delete(id: record.id)
        XCTAssertTrue(try sut.progressRepository.fetchRecords(conditionID: condition.id).isEmpty)
    }

    func testDeletingConditionCascadesProgressRecords() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try Condition(
            wishID: wish.id,
            title: "阅读",
            type: .duration,
            targetValue: 30,
            unit: "小时",
            createdAt: now
        )
        try sut.conditionRepository.save(condition)

        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 2,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        try sut.progressRepository.save(record)

        try sut.conditionRepository.delete(id: condition.id)

        XCTAssertNil(try sut.conditionRepository.fetch(id: condition.id))
        XCTAssertTrue(try sut.progressRepository.fetchRecords(conditionID: condition.id).isEmpty)
    }

    func testDeletingWishCascadesAllRelatedData() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            createdAt: now
        )
        try sut.conditionRepository.save(condition)

        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        try sut.progressRepository.save(record)

        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: now,
            conditionSnapshot: #"{"count":1}"#,
            createdAt: now
        )
        try sut.unlockEventRepository.save(event)

        let period = try WishPausePeriod(wishID: wish.id, startedAt: now)
        try sut.pausePeriodRepository.save(period)

        try sut.wishRepository.delete(id: wish.id)

        XCTAssertTrue(try sut.wishRepository.fetchAll().isEmpty)
        XCTAssertTrue(try sut.conditionRepository.fetchConditions(wishID: wish.id).isEmpty)
        XCTAssertTrue(try sut.progressRepository.fetchRecords(conditionID: condition.id).isEmpty)
        XCTAssertTrue(try sut.unlockEventRepository.fetchEvents(wishID: wish.id).isEmpty)
        XCTAssertTrue(try sut.pausePeriodRepository.fetchPeriods(wishID: wish.id).isEmpty)
    }

    func testUnlockEventAppendOnlyAndExistsCheck() throws {
        let sut = try makeSUT()
        let wish = try makeWish()

        XCTAssertFalse(try sut.unlockEventRepository.hasEvent(wishID: wish.id))

        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: now,
            conditionSnapshot: #"{"count":2}"#,
            createdAt: now
        )
        try sut.unlockEventRepository.save(event)

        XCTAssertTrue(try sut.unlockEventRepository.hasEvent(wishID: wish.id))
        XCTAssertEqual(try sut.unlockEventRepository.fetchEvents(wishID: wish.id), [event])
    }

    func testPausePeriodCRUD() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        let period = try WishPausePeriod(wishID: wish.id, startedAt: now)

        try sut.pausePeriodRepository.save(period)
        XCTAssertEqual(try sut.pausePeriodRepository.fetchPeriods(wishID: wish.id), [period])
        XCTAssertTrue(try sut.pausePeriodRepository.fetchPeriods(wishID: wish.id).first?.isOpen == true)

        let closed = try WishPausePeriod(
            id: period.id,
            wishID: wish.id,
            startedAt: now,
            endedAt: later
        )
        try sut.pausePeriodRepository.save(closed)

        XCTAssertEqual(try sut.pausePeriodRepository.fetchPeriods(wishID: wish.id).first?.endedAt, later)

        try sut.pausePeriodRepository.delete(id: period.id)
        XCTAssertTrue(try sut.pausePeriodRepository.fetchPeriods(wishID: wish.id).isEmpty)
    }

    func testMapperRejectsUnknownStatusRawValue() {
        let entity = WishEntity(
            id: UUID(),
            title: "Kindle",
            wishDescription: nil,
            imagePath: nil,
            targetPrice: nil,
            currencyCode: "CNY",
            targetDate: nil,
            statusRaw: "unknown-status",
            createdAt: now,
            updatedAt: now,
            unlockedAt: nil,
            completedAt: nil
        )

        XCTAssertThrowsError(try WishMapper.toDomain(entity)) { error in
            guard let persistenceError = error as? PersistenceError,
                  case .fetchFailed = persistenceError else {
                return XCTFail("Expected PersistenceError.fetchFailed")
            }
        }
    }
}
