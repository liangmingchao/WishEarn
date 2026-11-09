import XCTest
@testable import WishEarn

@MainActor
final class WishUnlockServiceTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000090")!

    private struct SUT {
        let service: WishUnlockService
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
        let eventRepository: MockUnlockEventRepository
    }

    private func makeSUT(
        publisher: UnlockEventPublishing? = nil
    ) -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let pauseRepository = MockWishPausePeriodRepository()
        let eventRepository = MockUnlockEventRepository()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let calculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let progressService = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pauseRepository,
            progressCalculator: calculator
        )
        let service = WishUnlockService(
            wishRepository: wishRepository,
            unlockEventRepository: eventRepository,
            progressService: progressService,
            clock: clock,
            unlockPublisher: publisher
        )
        return SUT(
            service: service,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            eventRepository: eventRepository
        )
    }

    private func makeWish(
        status: WishStatus = .active
    ) throws -> Wish {
        try Wish(
            id: wishID,
            title: "Kindle",
            status: status,
            createdAt: now,
            updatedAt: now
        )
    }

    private func makeCondition(
        title: String = "健身",
        targetValue: Decimal = 10,
        isRequired: Bool = true
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: title,
            type: .count,
            targetValue: targetValue,
            unit: "次",
            isRequired: isRequired,
            createdAt: now
        )
    }

    private func makeRecord(
        conditionID: UUID,
        value: Decimal
    ) throws -> ProgressRecord {
        try ProgressRecord(
            conditionID: conditionID,
            value: value,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
    }

    func testUnlocksWhenAllRequiredConditionsComplete() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id, value: 10))

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .unlocked)
        let updated = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))
        XCTAssertEqual(updated.status, .unlocked)
        XCTAssertEqual(updated.unlockedAt, now)
        XCTAssertEqual(sut.eventRepository.events.count, 1)
        XCTAssertTrue(sut.eventRepository.events[0].conditionSnapshot.contains("健身"))
    }

    func testPartialProgressIsNotEligible() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id, value: 5))

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .notEligible)
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .active)
        XCTAssertTrue(sut.eventRepository.events.isEmpty)
    }

    func testNoRequiredConditionsIsNotEligible() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let optional = try makeCondition(isRequired: false)
        try sut.conditionRepository.save(optional)
        try sut.progressRepository.save(makeRecord(conditionID: optional.id, value: 10))

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .notEligible)
        XCTAssertTrue(sut.eventRepository.events.isEmpty)
    }

    func testPausedWishIsNotEligible() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id, value: 10))

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .notEligible)
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .paused)
        XCTAssertTrue(sut.eventRepository.events.isEmpty)
    }

    func testAlreadyUnlockedWishIsIdempotent() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .unlocked)
        try sut.wishRepository.save(wish)

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .alreadyUnlocked)
        XCTAssertTrue(sut.eventRepository.events.isEmpty)
    }

    func testExistingEventRecoversActiveWish() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: now,
            conditionSnapshot: "[]",
            createdAt: now
        )
        try sut.eventRepository.save(event)

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .alreadyUnlocked)
        XCTAssertEqual(try sut.wishRepository.fetch(id: wish.id)?.status, .unlocked)
        XCTAssertEqual(sut.eventRepository.events.count, 1)
    }

    func testExistingEventRecoversActiveWishWithEventTimestamp() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let eventTime = TestDates.make(year: 2026, month: 11, day: 7)
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: eventTime,
            conditionSnapshot: "[]",
            createdAt: eventTime
        )
        try sut.eventRepository.save(event)

        XCTAssertEqual(try sut.service.evaluateUnlock(wishID: wish.id), .alreadyUnlocked)

        let updated = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))
        XCTAssertEqual(updated.status, .unlocked)
        XCTAssertEqual(updated.unlockedAt, eventTime)
        XCTAssertEqual(sut.eventRepository.events, [event])
    }

    func testExistingEventRecoversPausedWish() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)
        let eventTime = TestDates.make(year: 2026, month: 11, day: 7)
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: eventTime,
            conditionSnapshot: "[]",
            createdAt: eventTime
        )
        try sut.eventRepository.save(event)

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .alreadyUnlocked)
        let updated = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))
        XCTAssertEqual(updated.status, .unlocked)
        XCTAssertEqual(updated.unlockedAt, eventTime)
        XCTAssertEqual(sut.eventRepository.events, [event])
    }

    func testExistingEventRecoversArchivedWish() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .archived)
        try sut.wishRepository.save(wish)
        let eventTime = TestDates.make(year: 2026, month: 11, day: 7)
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: eventTime,
            conditionSnapshot: "[]",
            createdAt: eventTime
        )
        try sut.eventRepository.save(event)

        let result = try sut.service.evaluateUnlock(wishID: wish.id)

        XCTAssertEqual(result, .alreadyUnlocked)
        let updated = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))
        XCTAssertEqual(updated.status, .unlocked)
        XCTAssertEqual(updated.unlockedAt, eventTime)
        XCTAssertEqual(sut.eventRepository.events, [event])
    }

    func testRepeatedEvaluationCreatesSingleEvent() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id, value: 10))

        XCTAssertEqual(try sut.service.evaluateUnlock(wishID: wish.id), .unlocked)
        XCTAssertEqual(try sut.service.evaluateUnlock(wishID: wish.id), .alreadyUnlocked)
        XCTAssertEqual(sut.eventRepository.events.count, 1)
    }

    func testNewUnlockPublishesEvent() throws {
        let publisher = MockUnlockEventPublisher()
        let sut = makeSUT(publisher: publisher)
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id, value: 10))

        XCTAssertEqual(try sut.service.evaluateUnlock(wishID: wish.id), .unlocked)
        XCTAssertEqual(publisher.publishedWishIDs, [wish.id])
    }

    func testPartialProgressDoesNotPublishEvent() throws {
        let publisher = MockUnlockEventPublisher()
        let sut = makeSUT(publisher: publisher)
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id, value: 5))

        XCTAssertEqual(try sut.service.evaluateUnlock(wishID: wish.id), .notEligible)
        XCTAssertTrue(publisher.publishedWishIDs.isEmpty)
    }

    func testAlreadyUnlockedDoesNotPublishEvent() throws {
        let publisher = MockUnlockEventPublisher()
        let sut = makeSUT(publisher: publisher)
        let wish = try makeWish(status: .unlocked)
        try sut.wishRepository.save(wish)

        XCTAssertEqual(try sut.service.evaluateUnlock(wishID: wish.id), .alreadyUnlocked)
        XCTAssertTrue(publisher.publishedWishIDs.isEmpty)
    }
}
