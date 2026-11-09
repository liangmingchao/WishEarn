import XCTest
@testable import WishEarn

@MainActor
final class ProgressCalculatorTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000070")!

    private func makeCalculator() -> ProgressCalculator {
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        return ProgressCalculator(streakCalculator: StreakCalculator(clock: clock))
    }

    private func makeCondition(
        type: ConditionType = .count,
        targetValue: Decimal = 10,
        unit: String? = "次",
        amountDirection: AmountDirection? = nil
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: "条件",
            type: type,
            targetValue: targetValue,
            unit: unit,
            amountDirection: amountDirection,
            createdAt: now
        )
    }

    private func makeRecords(
        conditionID: UUID,
        values: [Decimal],
        days: [Int] = [6, 7, 8]
    ) throws -> [ProgressRecord] {
        try zip(values, days).map { value, day in
            let date = TestDates.make(year: 2026, month: 11, day: day)
            return try ProgressRecord(
                conditionID: conditionID,
                value: value,
                recordedAt: date,
                createdAt: date,
                updatedAt: date
            )
        }
    }

    func testCountProgress() throws {
        let condition = try makeCondition(targetValue: 10)
        let records = try makeRecords(conditionID: condition.id, values: [5, 3])
        let snapshot = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )

        XCTAssertEqual(snapshot.currentValue, 8)
        XCTAssertEqual(snapshot.targetValue, 10)
        XCTAssertEqual(snapshot.progressRatio, 0.8, accuracy: 0.0001)
        XCTAssertEqual(snapshot.remainingValue, 2)
        XCTAssertFalse(snapshot.isCompleted)
        XCTAssertEqual(snapshot.lastRecordedAt, TestDates.make(year: 2026, month: 11, day: 7))
    }

    func testProgressClampsAtOne() throws {
        let condition = try makeCondition(targetValue: 10)
        let records = try makeRecords(conditionID: condition.id, values: [12])
        let snapshot = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )

        XCTAssertEqual(snapshot.progressRatio, 1)
        XCTAssertEqual(snapshot.remainingValue, 0)
        XCTAssertTrue(snapshot.isCompleted)
    }

    func testAmountProgressUsesDecimalValues() throws {
        let condition = try makeCondition(
            type: .amount,
            targetValue: 1000,
            unit: "元",
            amountDirection: .income
        )
        let first = try XCTUnwrap(Decimal(string: "300.50"))
        let second = try XCTUnwrap(Decimal(string: "200.50"))
        let total = try XCTUnwrap(Decimal(string: "501.00"))
        let records = try makeRecords(
            conditionID: condition.id,
            values: [first, second]
        )

        let snapshot = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )

        XCTAssertEqual(snapshot.currentValue, total)
        XCTAssertEqual(snapshot.progressRatio, 0.501, accuracy: 0.0001)
        XCTAssertEqual(snapshot.remainingValue, 499)
    }

    func testCheckpointProgress() throws {
        let condition = try makeCondition(type: .checkpoint, targetValue: 1, unit: nil)

        let empty = makeCalculator().calculate(
            condition: condition,
            records: [],
            pausePeriods: []
        )
        XCTAssertEqual(empty.currentValue, 0)
        XCTAssertFalse(empty.isCompleted)
        XCTAssertEqual(empty.remainingValue, 1)

        let records = try makeRecords(
            conditionID: condition.id,
            values: [1],
            days: [7]
        )
        let completed = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )
        XCTAssertEqual(completed.currentValue, 1)
        XCTAssertTrue(completed.isCompleted)
        XCTAssertEqual(completed.progressRatio, 1)
        XCTAssertEqual(completed.remainingValue, 0)
    }

    func testStreakProgressUsesCurrentStreak() throws {
        let condition = try makeCondition(type: .streak, targetValue: 3, unit: "天")
        let records = try makeRecords(
            conditionID: condition.id,
            values: [1, 1, 1],
            days: [6, 7, 8]
        )

        let snapshot = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )

        XCTAssertEqual(snapshot.currentValue, 3)
        XCTAssertEqual(snapshot.progressRatio, 1)
        XCTAssertTrue(snapshot.isCompleted)
    }

    func testCustomProgressUsesAccumulatedValue() throws {
        let condition = try makeCondition(type: .custom, targetValue: 300, unit: "页")
        let records = try makeRecords(conditionID: condition.id, values: [100, 50])

        let snapshot = makeCalculator().calculate(
            condition: condition,
            records: records,
            pausePeriods: []
        )

        XCTAssertEqual(snapshot.currentValue, 150)
        XCTAssertEqual(snapshot.progressRatio, 0.5, accuracy: 0.0001)
    }

    func testEmptyRecordsHaveZeroProgress() throws {
        let condition = try makeCondition(targetValue: 20)
        let snapshot = makeCalculator().calculate(
            condition: condition,
            records: [],
            pausePeriods: []
        )

        XCTAssertEqual(snapshot.currentValue, 0)
        XCTAssertEqual(snapshot.progressRatio, 0)
        XCTAssertEqual(snapshot.remainingValue, 20)
        XCTAssertFalse(snapshot.isCompleted)
        XCTAssertNil(snapshot.lastRecordedAt)
    }
}
