import XCTest
@testable import WishEarn

@MainActor
final class EndToEndFlowTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private struct SUT {
        let wishRepository: SwiftDataWishRepository
        let conditionRepository: SwiftDataConditionRepository
        let progressRepository: SwiftDataProgressRepository
        let eventRepository: SwiftDataUnlockEventRepository
        let lifecycleService: WishLifecycleService
        let conditionService: ConditionLifecycleService
        let recordService: ProgressRecordService
        let progressService: WishProgressService
    }

    private func makeSUT() throws -> SUT {
        let container = try ModelContainerFactory.make(inMemory: true)
        let store = SwiftDataStore(container: container)
        let wishRepository = SwiftDataWishRepository(store: store)
        let conditionRepository = SwiftDataConditionRepository(store: store)
        let progressRepository = SwiftDataProgressRepository(store: store)
        let eventRepository = SwiftDataUnlockEventRepository(store: store)
        let pauseRepository = SwiftDataWishPausePeriodRepository(store: store)
        let clock = FixedClock(now: now, calendar: TestDates.calendar)

        let progressCalculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let progressService = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pauseRepository,
            progressCalculator: progressCalculator
        )
        let unlockService = WishUnlockService(
            wishRepository: wishRepository,
            unlockEventRepository: eventRepository,
            progressService: progressService,
            clock: clock
        )
        let lifecycleService = WishLifecycleService(
            wishRepository: wishRepository,
            pausePeriodRepository: pauseRepository,
            clock: clock
        )
        let conditionService = ConditionLifecycleService(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            clock: clock,
            unlockService: unlockService
        )
        let recordService = ProgressRecordService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            clock: clock,
            unlockService: unlockService
        )

        return SUT(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            eventRepository: eventRepository,
            lifecycleService: lifecycleService,
            conditionService: conditionService,
            recordService: recordService,
            progressService: progressService
        )
    }

    private func makeWish() throws -> Wish {
        try Wish(title: "Kindle", targetPrice: 1099, createdAt: now, updatedAt: now)
    }

    private func makeDraft(
        wishID: UUID,
        title: String,
        type: ConditionType,
        targetValue: Decimal,
        unit: String?,
        amountDirection: AmountDirection? = nil,
        sortOrder: Int
    ) -> ConditionDraft {
        ConditionDraft(
            wishID: wishID,
            title: title,
            description: nil,
            type: type,
            targetValue: targetValue,
            unit: unit,
            amountDirection: amountDirection,
            isRequired: true,
            sortOrder: sortOrder
        )
    }

    private func makeRecordDraft(
        conditionID: UUID,
        value: Decimal
    ) -> ProgressRecordDraft {
        ProgressRecordDraft(
            conditionID: conditionID,
            value: value,
            note: nil,
            recordedAt: now
        )
    }

    func testFullFlowUnlockAndComplete() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)

        let count = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "健身",
                type: .count,
                targetValue: 10,
                unit: "次",
                sortOrder: 0
            )
        )
        let checkpoint = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "完成项目",
                type: .checkpoint,
                targetValue: 1,
                unit: nil,
                sortOrder: 1
            )
        )

        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: count.id, value: 10)
        )
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .active
        )

        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: checkpoint.id, value: 1)
        )

        let unlocked = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))
        XCTAssertEqual(unlocked.status, .unlocked)
        XCTAssertEqual(unlocked.unlockedAt, now)
        XCTAssertTrue(try sut.eventRepository.hasEvent(wishID: wish.id))

        try sut.lifecycleService.complete(wishID: wish.id)

        let completed = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))
        XCTAssertEqual(completed.status, .completed)
        XCTAssertEqual(completed.completedAt, now)
    }

    func testPartialConditionsDoNotUnlock() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)
        let condition = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "健身",
                type: .count,
                targetValue: 10,
                unit: "次",
                sortOrder: 0
            )
        )

        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: condition.id, value: 5)
        )

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .active)
        XCTAssertFalse(try sut.eventRepository.hasEvent(wishID: wish.id))
    }

    func testDeletingRecordAfterUnlockKeepsEventAndUnlockedStatus() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)
        let condition = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "健身",
                type: .count,
                targetValue: 10,
                unit: "次",
                sortOrder: 0
            )
        )
        let record = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: condition.id, value: 10)
        )
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)

        try sut.recordService.delete(recordID: record.id)

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)
        XCTAssertTrue(try sut.eventRepository.hasEvent(wishID: wish.id))
    }

    func testUpdatingConditionTargetTriggersUnlock() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)
        let condition = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "健身",
                type: .count,
                targetValue: 10,
                unit: "次",
                sortOrder: 0
            )
        )
        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: condition.id, value: 5)
        )
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .active)

        let loweredTarget = try Condition(
            id: condition.id,
            wishID: condition.wishID,
            title: condition.title,
            type: condition.type,
            targetValue: 5,
            unit: condition.unit,
            isRequired: condition.isRequired,
            sortOrder: condition.sortOrder,
            createdAt: condition.createdAt
        )
        try sut.conditionService.updateCondition(loweredTarget)

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)
    }

    func testAmountFlowUnlocks() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)
        let amount = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "兼职收入",
                type: .amount,
                targetValue: 1000,
                unit: "元",
                amountDirection: .income,
                sortOrder: 0
            )
        )

        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: amount.id, value: 600)
        )
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .active)

        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: amount.id, value: 400)
        )

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)
    }

    func testDeletingConditionAfterUnlockKeepsEventAndStatus() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)
        let condition = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "健身",
                type: .count,
                targetValue: 10,
                unit: "次",
                sortOrder: 0
            )
        )
        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: condition.id, value: 10)
        )
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)

        try sut.conditionService.delete(conditionID: condition.id)

        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)
        XCTAssertTrue(try sut.eventRepository.hasEvent(wishID: wish.id))
    }

    func testPauseAndResumeKeepsRecords() throws {
        let sut = try makeSUT()
        let wish = try makeWish()
        try sut.lifecycleService.createWish(wish)
        let condition = try sut.conditionService.createCondition(
            makeDraft(
                wishID: wish.id,
                title: "健身",
                type: .count,
                targetValue: 10,
                unit: "次",
                sortOrder: 0
            )
        )
        _ = try sut.recordService.createRecord(
            makeRecordDraft(conditionID: condition.id, value: 3)
        )

        try sut.lifecycleService.pause(wishID: wish.id)
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .paused)

        try sut.lifecycleService.resume(wishID: wish.id)
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .active)
        XCTAssertEqual(
            try sut.progressRepository.fetchRecords(conditionID: condition.id).count,
            1
        )
    }
}
