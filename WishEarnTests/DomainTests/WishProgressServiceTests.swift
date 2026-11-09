import XCTest
@testable import WishEarn

@MainActor
final class WishProgressServiceTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000080")!

    private struct SUT {
        let service: WishProgressService
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
        let pauseRepository: MockWishPausePeriodRepository
    }

    private func makeSUT() -> SUT {
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let pauseRepository = MockWishPausePeriodRepository()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let calculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let service = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pauseRepository,
            progressCalculator: calculator
        )
        return SUT(
            service: service,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pauseRepository: pauseRepository
        )
    }

    private func makeWish() throws -> Wish {
        try Wish(id: wishID, title: "Kindle", createdAt: now, updatedAt: now)
    }

    private func makeCondition(
        title: String,
        targetValue: Decimal,
        isRequired: Bool = true,
        type: ConditionType = .count
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: title,
            type: type,
            targetValue: targetValue,
            unit: "次",
            isRequired: isRequired,
            createdAt: now
        )
    }

    private func makeRecord(
        conditionID: UUID,
        value: Decimal,
        day: Int = 8
    ) throws -> ProgressRecord {
        let date = TestDates.make(year: 2026, month: 11, day: day)
        return try ProgressRecord(
            conditionID: conditionID,
            value: value,
            recordedAt: date,
            createdAt: date,
            updatedAt: date
        )
    }

    func testOverallProgressUsesRequiredConditions() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        let first = try makeCondition(title: "健身", targetValue: 10)
        let second = try makeCondition(title: "阅读", targetValue: 10)
        let optional = try makeCondition(title: "可选", targetValue: 10, isRequired: false)

        try sut.conditionRepository.save(first)
        try sut.conditionRepository.save(second)
        try sut.conditionRepository.save(optional)
        try sut.progressRepository.save(makeRecord(conditionID: first.id, value: 10))
        try sut.progressRepository.save(makeRecord(conditionID: second.id, value: 5))
        try sut.progressRepository.save(makeRecord(conditionID: optional.id, value: 10))

        let progress = try sut.service.progress(for: wish)

        XCTAssertEqual(progress.requiredTotal, 2)
        XCTAssertEqual(progress.requiredCompleted, 1)
        XCTAssertEqual(progress.overallRatio, 0.5, accuracy: 0.0001)
        XCTAssertFalse(progress.isUnlockable)
        XCTAssertEqual(progress.conditions.count, 3)
    }

    func testAllRequiredCompletedIsUnlockable() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        let first = try makeCondition(title: "健身", targetValue: 10)
        let second = try makeCondition(title: "阅读", targetValue: 10)

        try sut.conditionRepository.save(first)
        try sut.conditionRepository.save(second)
        try sut.progressRepository.save(makeRecord(conditionID: first.id, value: 10))
        try sut.progressRepository.save(makeRecord(conditionID: second.id, value: 10))

        let progress = try sut.service.progress(for: wish)

        XCTAssertEqual(progress.requiredCompleted, 2)
        XCTAssertEqual(progress.overallRatio, 1)
        XCTAssertTrue(progress.isUnlockable)
    }

    func testNoRequiredConditionsIsNotUnlockable() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        let optional = try makeCondition(title: "可选", targetValue: 10, isRequired: false)
        try sut.conditionRepository.save(optional)

        let progress = try sut.service.progress(for: wish)

        XCTAssertEqual(progress.requiredTotal, 0)
        XCTAssertEqual(progress.overallRatio, 0)
        XCTAssertFalse(progress.isUnlockable)
    }

    func testStreakProgressUsesPausePeriods() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        let streak = try makeCondition(
            title: "连续坚持",
            targetValue: 2,
            type: .streak
        )
        try sut.conditionRepository.save(streak)
        try sut.progressRepository.save(makeRecord(conditionID: streak.id, value: 1, day: 6))
        try sut.progressRepository.save(makeRecord(conditionID: streak.id, value: 1, day: 7))
        try sut.pauseRepository.save(
            try WishPausePeriod(
                wishID: wishID,
                startedAt: TestDates.make(year: 2026, month: 11, day: 8)
            )
        )

        let progress = try sut.service.progress(for: wish)
        let item = try XCTUnwrap(progress.conditions.first)

        XCTAssertEqual(item.snapshot.currentValue, 2)
        XCTAssertTrue(item.snapshot.isCompleted)
        XCTAssertTrue(progress.isUnlockable)
    }
}
