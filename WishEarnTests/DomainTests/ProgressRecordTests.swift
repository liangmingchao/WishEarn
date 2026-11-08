import XCTest
@testable import WishEarn

final class ProgressRecordTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let conditionID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    func testCreatesValidRecord() throws {
        let record = try ProgressRecord(
            conditionID: conditionID,
            value: Decimal(string: "300.50")!,
            note: "兼职",
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )

        XCTAssertEqual(record.conditionID, conditionID)
        XCTAssertEqual(record.value, Decimal(string: "300.50"))
        XCTAssertEqual(record.note, "兼职")
    }

    func testRejectsNegativeValue() {
        XCTAssertThrowsError(
            try ProgressRecord(
                conditionID: conditionID,
                value: -1,
                recordedAt: now,
                createdAt: now,
                updatedAt: now
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("记录值不能为负数。"))
        }
    }

    func testUpdateUsesInjectedTimestamp() throws {
        var record = try ProgressRecord(
            conditionID: conditionID,
            value: 1,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        let later = TestDates.make(year: 2026, month: 11, day: 9)

        try record.update(value: 3, note: "修改", recordedAt: later, now: later)

        XCTAssertEqual(record.value, 3)
        XCTAssertEqual(record.note, "修改")
        XCTAssertEqual(record.recordedAt, later)
        XCTAssertEqual(record.updatedAt, later)
    }
}
