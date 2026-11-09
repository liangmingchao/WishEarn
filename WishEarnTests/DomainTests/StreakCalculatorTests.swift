import XCTest
@testable import WishEarn

@MainActor
final class StreakCalculatorTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000060")!

    private func makeCalculator() -> StreakCalculator {
        StreakCalculator(clock: FixedClock(now: now, calendar: TestDates.calendar))
    }

    private func makeCondition(targetValue: Decimal = 5) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: "连续坚持",
            type: .streak,
            targetValue: targetValue,
            unit: "天",
            createdAt: now
        )
    }

    private func makeRecords(days: [Int], month: Int = 11) throws -> [ProgressRecord] {
        try days.map { day in
            let date = TestDates.make(year: 2026, month: month, day: day)
            return try ProgressRecord(
                conditionID: UUID(),
                value: 1,
                recordedAt: date,
                createdAt: date,
                updatedAt: date
            )
        }
    }

    private func makePause(
        startDay: Int,
        endDay: Int? = nil
    ) throws -> WishPausePeriod {
        try WishPausePeriod(
            wishID: wishID,
            startedAt: TestDates.make(year: 2026, month: 11, day: startDay),
            endedAt: endDay.map { TestDates.make(year: 2026, month: 11, day: $0) }
        )
    }

    func testConsecutiveDaysEndingToday() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [6, 7, 8]),
            pausePeriods: []
        )

        XCTAssertEqual(result.currentStreak, 3)
        XCTAssertEqual(result.longestStreak, 3)
        XCTAssertFalse(result.isCompleted)
    }

    func testLastRecordYesterdayKeepsCurrentStreak() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [5, 6, 7]),
            pausePeriods: []
        )

        XCTAssertEqual(result.currentStreak, 3)
        XCTAssertEqual(result.longestStreak, 3)
    }

    func testMissedYesterdayResetsCurrentStreak() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [5, 6]),
            pausePeriods: []
        )

        XCTAssertEqual(result.currentStreak, 0)
        XCTAssertEqual(result.longestStreak, 2)
    }

    func testGapResetsCurrentButKeepsLongest() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [5, 6, 8]),
            pausePeriods: []
        )

        XCTAssertEqual(result.currentStreak, 1)
        XCTAssertEqual(result.longestStreak, 2)
    }

    func testOpenPauseFreezesCurrentStreak() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [5, 6]),
            pausePeriods: [try makePause(startDay: 7)]
        )

        XCTAssertEqual(result.currentStreak, 2)
        XCTAssertEqual(result.longestStreak, 2)
    }

    func testResumeDayRecordContinuesStreak() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [5, 6, 8]),
            pausePeriods: [try makePause(startDay: 7, endDay: 8)]
        )

        XCTAssertEqual(result.currentStreak, 3)
        XCTAssertEqual(result.longestStreak, 3)
    }

    func testRecordOnPausedDayIsIgnored() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [5, 6, 7]),
            pausePeriods: [try makePause(startDay: 7)]
        )

        XCTAssertEqual(result.currentStreak, 2)
        XCTAssertEqual(result.longestStreak, 2)
    }

    func testMultiplePausePeriods() throws {
        let condition = try makeCondition()
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [1, 2, 5, 6, 8]),
            pausePeriods: [
                try makePause(startDay: 3, endDay: 5),
                try makePause(startDay: 7, endDay: 8)
            ]
        )

        XCTAssertEqual(result.currentStreak, 5)
        XCTAssertEqual(result.longestStreak, 5)
    }

    func testCompletedWhenCurrentStreakReachesTarget() throws {
        let condition = try makeCondition(targetValue: 3)
        let result = makeCalculator().calculate(
            condition: condition,
            records: try makeRecords(days: [6, 7, 8]),
            pausePeriods: []
        )

        XCTAssertTrue(result.isCompleted)
    }

    func testSameDayDuplicateRecordCountsOnce() throws {
        let condition = try makeCondition()
        let records = try makeRecords(days: [7, 8, 8])
        let result = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )

        XCTAssertEqual(result.currentStreak, 2)
        XCTAssertEqual(result.longestStreak, 2)
    }
}
