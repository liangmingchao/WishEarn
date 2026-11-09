import XCTest
@testable import WishEarn

@MainActor
final class UnlockRecoveryTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let earlier = TestDates.make(year: 2026, month: 11, day: 7)

    private struct SUT {
        let service: WishUnlockService
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
        let eventRepository: MockUnlockEventRepository
    }

    private func makeSUT() -> SUT {
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
            clock: clock
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
        id: UUID = UUID(),
        status: WishStatus = .active,
        unlockedAt: Date? = nil,
        completedAt: Date? = nil
    ) throws -> Wish {
        try Wish(
            id: id,
            title: "Kindle",
            status: status,
            createdAt: now,
            updatedAt: now,
            unlockedAt: unlockedAt,
            completedAt: completedAt
        )
    }

    private func makeCondition(
        wishID: UUID,
        targetValue: Decimal = 10
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: "健身",
            type: .count,
            targetValue: targetValue,
            unit: "次",
            createdAt: now
        )
    }

    private func makeRecord(conditionID: UUID) throws -> ProgressRecord {
        try ProgressRecord(
            conditionID: conditionID,
            value: 10,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
    }

    private func makeEvent(
        wishID: UUID,
        unlockedAt: Date,
        snapshot: String = #"{"count":1}"#
    ) throws -> UnlockEvent {
        try UnlockEvent(
            wishID: wishID,
            unlockedAt: unlockedAt,
            conditionSnapshot: snapshot,
            createdAt: unlockedAt
        )
    }

    func testRecoveryRestoresActivePausedAndArchivedWishesFromEvents() throws {
        let sut = makeSUT()
        let active = try makeWish(status: .active)
        let paused = try makeWish(status: .paused)
        let archived = try makeWish(status: .archived)
        try sut.wishRepository.save(active)
        try sut.wishRepository.save(paused)
        try sut.wishRepository.save(archived)

        let events = [
            try makeEvent(wishID: active.id, unlockedAt: earlier),
            try makeEvent(wishID: paused.id, unlockedAt: now),
            try makeEvent(wishID: archived.id, unlockedAt: earlier)
        ]
        for event in events {
            try sut.eventRepository.save(event)
        }

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(
            Set(report.restoredWishIDs),
            Set([active.id, paused.id, archived.id])
        )
        XCTAssertTrue(report.newlyUnlockedWishIDs.isEmpty)
        XCTAssertTrue(report.missingEventWishIDs.isEmpty)
        XCTAssertTrue(report.orphanedEventWishIDs.isEmpty)
        XCTAssertTrue(report.failures.isEmpty)

        let restored = try sut.wishRepository.fetchAll()
        XCTAssertTrue(restored.allSatisfy { $0.status == .unlocked })
        XCTAssertEqual(
            restored.first { $0.id == active.id }?.unlockedAt,
            earlier
        )
        XCTAssertEqual(
            restored.first { $0.id == paused.id }?.unlockedAt,
            now
        )
        XCTAssertEqual(
            restored.first { $0.id == archived.id }?.unlockedAt,
            earlier
        )
        XCTAssertEqual(sut.eventRepository.events.count, 3)
    }

    func testRecoveryDoesNotDowngradeUnlockedOrCompletedWishes() throws {
        let sut = makeSUT()
        let unlocked = try makeWish(
            status: .unlocked,
            unlockedAt: earlier
        )
        let completed = try makeWish(
            status: .completed,
            unlockedAt: earlier,
            completedAt: now
        )
        try sut.wishRepository.save(unlocked)
        try sut.wishRepository.save(completed)
        try sut.eventRepository.save(
            makeEvent(wishID: unlocked.id, unlockedAt: earlier)
        )
        try sut.eventRepository.save(
            makeEvent(wishID: completed.id, unlockedAt: earlier)
        )

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(report.isEmpty)
        let fetched = try sut.wishRepository.fetchAll()
        let restoredUnlocked = try XCTUnwrap(fetched.first { $0.id == unlocked.id })
        let restoredCompleted = try XCTUnwrap(fetched.first { $0.id == completed.id })
        XCTAssertEqual(restoredUnlocked.status, .unlocked)
        XCTAssertEqual(restoredUnlocked.unlockedAt, earlier)
        XCTAssertEqual(restoredCompleted.status, .completed)
        XCTAssertEqual(restoredCompleted.unlockedAt, earlier)
        XCTAssertEqual(restoredCompleted.completedAt, now)
        XCTAssertEqual(sut.eventRepository.events.count, 2)
    }

    func testRecoveryReportsMissingEventsWithoutRevokingStatus() throws {
        let sut = makeSUT()
        let unlocked = try makeWish(status: .unlocked, unlockedAt: now)
        let completed = try makeWish(
            status: .completed,
            unlockedAt: now,
            completedAt: now
        )
        try sut.wishRepository.save(unlocked)
        try sut.wishRepository.save(completed)

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(
            Set(report.missingEventWishIDs),
            Set([unlocked.id, completed.id])
        )
        XCTAssertTrue(report.restoredWishIDs.isEmpty)
        XCTAssertTrue(report.newlyUnlockedWishIDs.isEmpty)
        XCTAssertTrue(report.orphanedEventWishIDs.isEmpty)
        XCTAssertTrue(report.failures.isEmpty)

        let fetched = try sut.wishRepository.fetchAll()
        XCTAssertEqual(
            fetched.first { $0.id == unlocked.id }?.status,
            .unlocked
        )
        XCTAssertEqual(
            fetched.first { $0.id == completed.id }?.status,
            .completed
        )
        XCTAssertTrue(sut.eventRepository.events.isEmpty)
    }

    func testRecoveryReportsOrphanedEventWithoutDeletingIt() throws {
        let sut = makeSUT()
        let orphanWishID = UUID()
        let event = try makeEvent(wishID: orphanWishID, unlockedAt: earlier)
        try sut.eventRepository.save(event)

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(report.orphanedEventWishIDs, [orphanWishID])
        XCTAssertTrue(report.restoredWishIDs.isEmpty)
        XCTAssertTrue(report.failures.isEmpty)
        XCTAssertEqual(sut.eventRepository.events, [event])
    }

    func testRecoveryIsIdempotentAndPreservesEvent() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let event = try makeEvent(wishID: wish.id, unlockedAt: earlier)
        try sut.eventRepository.save(event)

        let firstReport = try sut.service.recoverUnlockConsistency()
        XCTAssertEqual(firstReport.restoredWishIDs, [wish.id])
        let afterFirstRun = try XCTUnwrap(sut.wishRepository.fetch(id: wish.id))

        let secondReport = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(secondReport.isEmpty)
        XCTAssertEqual(sut.eventRepository.events, [event])
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id),
            afterFirstRun
        )
        XCTAssertEqual(afterFirstRun.status, .unlocked)
        XCTAssertEqual(afterFirstRun.unlockedAt, earlier)
    }

    func testRecoveryCreatesOneEventForEligibleActiveWishAndIsIdempotent() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition(wishID: wish.id)
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id))

        let firstReport = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(firstReport.newlyUnlockedWishIDs, [wish.id])
        XCTAssertEqual(sut.eventRepository.events.count, 1)
        let event = try XCTUnwrap(sut.eventRepository.events.first)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )

        let secondReport = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(secondReport.isEmpty)
        XCTAssertEqual(sut.eventRepository.events, [event])
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )
    }

    func testRecoveryDoesNotUnlockPausedWishWithoutEvent() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)
        let condition = try makeCondition(wishID: wish.id)
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id))

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(report.isEmpty)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .paused
        )
        XCTAssertTrue(sut.eventRepository.events.isEmpty)
    }

    func testRecoveryContinuesWhenOneWishCannotBeSaved() throws {
        let sut = makeSUT()
        let failingWish = try makeWish()
        let healthyWish = try makeWish()
        try sut.wishRepository.save(failingWish)
        try sut.wishRepository.save(healthyWish)
        let failingEvent = try makeEvent(
            wishID: failingWish.id,
            unlockedAt: earlier
        )
        let healthyEvent = try makeEvent(
            wishID: healthyWish.id,
            unlockedAt: earlier
        )
        try sut.eventRepository.save(failingEvent)
        try sut.eventRepository.save(healthyEvent)
        sut.wishRepository.saveErrorByWishID[failingWish.id] =
            PersistenceError.saveFailed("状态写入失败")

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(report.failures.count, 1)
        XCTAssertEqual(report.failures.first?.wishID, failingWish.id)
        XCTAssertEqual(
            report.failures.first?.message,
            "保存数据失败：状态写入失败"
        )
        XCTAssertEqual(report.restoredWishIDs, [healthyWish.id])
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: failingWish.id)?.status,
            .active
        )
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: healthyWish.id)?.status,
            .unlocked
        )
        XCTAssertEqual(sut.eventRepository.events.count, 2)

        sut.wishRepository.saveErrorByWishID.removeAll()
        let retryReport = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(retryReport.failures.isEmpty)
        XCTAssertEqual(retryReport.restoredWishIDs, [failingWish.id])
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: failingWish.id)?.status,
            .unlocked
        )
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: failingWish.id)?.unlockedAt,
            earlier
        )
        XCTAssertEqual(
            Set(sut.eventRepository.events.map(\.id)),
            Set([failingEvent.id, healthyEvent.id])
        )
    }

    func testRecoveryCanRepairAfterEventSavedButStatusSaveFailed() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition(wishID: wish.id)
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id))
        sut.wishRepository.saveErrorByWishID[wish.id] =
            PersistenceError.saveFailed("状态写入失败")

        let firstReport = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(firstReport.failures.count, 1)
        XCTAssertEqual(firstReport.failures.first?.wishID, wish.id)
        XCTAssertTrue(firstReport.newlyUnlockedWishIDs.isEmpty)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .active
        )
        XCTAssertEqual(sut.eventRepository.events.count, 1)
        let persistedEvent = try XCTUnwrap(sut.eventRepository.events.first)

        sut.wishRepository.saveErrorByWishID.removeAll()
        let retryReport = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(retryReport.failures.isEmpty)
        XCTAssertEqual(retryReport.restoredWishIDs, [wish.id])
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )
        XCTAssertEqual(sut.eventRepository.events, [persistedEvent])
    }

    func testRecoveryReportsEventSaveFailureAndCanRetry() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition(wishID: wish.id)
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id))
        sut.eventRepository.saveError = PersistenceError.saveFailed("事件写入失败")

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(report.failures.count, 1)
        XCTAssertEqual(report.failures.first?.wishID, wish.id)
        XCTAssertEqual(
            report.failures.first?.message,
            "保存数据失败：事件写入失败"
        )
        XCTAssertTrue(report.newlyUnlockedWishIDs.isEmpty)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .active
        )
        XCTAssertTrue(sut.eventRepository.events.isEmpty)

        sut.eventRepository.saveError = nil
        let retryReport = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(retryReport.failures.isEmpty)
        XCTAssertEqual(retryReport.newlyUnlockedWishIDs, [wish.id])
        XCTAssertEqual(sut.eventRepository.events.count, 1)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )
    }

    func testRecoveryReportsEventReadFailureAndCanRetry() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try makeCondition(wishID: wish.id)
        try sut.conditionRepository.save(condition)
        try sut.progressRepository.save(makeRecord(conditionID: condition.id))
        sut.eventRepository.fetchEventsError =
            PersistenceError.fetchFailed("事件读取失败")

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(report.failures.count, 1)
        XCTAssertEqual(report.failures.first?.wishID, wish.id)
        XCTAssertEqual(
            report.failures.first?.message,
            "读取数据失败：事件读取失败"
        )
        XCTAssertTrue(report.newlyUnlockedWishIDs.isEmpty)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .active
        )
        XCTAssertTrue(sut.eventRepository.events.isEmpty)

        sut.eventRepository.fetchEventsError = nil
        let retryReport = try sut.service.recoverUnlockConsistency()

        XCTAssertTrue(retryReport.failures.isEmpty)
        XCTAssertEqual(retryReport.newlyUnlockedWishIDs, [wish.id])
        XCTAssertEqual(sut.eventRepository.events.count, 1)
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )
    }

    func testRecoveryThrowsWhenWishFetchFails() throws {
        let sut = makeSUT()
        sut.wishRepository.error = PersistenceError.fetchFailed("心愿读取失败")

        XCTAssertThrowsError(try sut.service.recoverUnlockConsistency()) { error in
            XCTAssertEqual(
                error as? PersistenceError,
                .fetchFailed("心愿读取失败")
            )
        }
    }

    func testRecoveryThrowsWhenEventFetchAllFails() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        sut.eventRepository.fetchAllError =
            PersistenceError.fetchFailed("事件读取失败")

        XCTAssertThrowsError(try sut.service.recoverUnlockConsistency()) { error in
            XCTAssertEqual(
                error as? PersistenceError,
                .fetchFailed("事件读取失败")
            )
        }
    }

    func testRecoveryKeepsAllEventsForWishWithoutDeletingOrOverwriting() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let first = try makeEvent(
            wishID: wish.id,
            unlockedAt: earlier,
            snapshot: #"{"count":1}"#
        )
        let second = try makeEvent(
            wishID: wish.id,
            unlockedAt: now,
            snapshot: #"{"count":2}"#
        )
        try sut.eventRepository.save(first)
        try sut.eventRepository.save(second)

        let report = try sut.service.recoverUnlockConsistency()

        XCTAssertEqual(report.restoredWishIDs, [wish.id])
        XCTAssertEqual(
            Set(sut.eventRepository.events.map(\.id)),
            Set([first.id, second.id])
        )
        XCTAssertEqual(
            sut.eventRepository.events.first { $0.id == first.id },
            first
        )
        XCTAssertEqual(
            sut.eventRepository.events.first { $0.id == second.id },
            second
        )
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )
        XCTAssertEqual(
            try sut.wishRepository.fetch(id: wish.id)?.unlockedAt,
            earlier
        )
    }
}
