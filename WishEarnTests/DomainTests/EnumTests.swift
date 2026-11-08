import XCTest
@testable import WishEarn

final class EnumTests: XCTestCase {
    func testWishStatusRawValues() {
        XCTAssertEqual(WishStatus.active.rawValue, "active")
        XCTAssertEqual(WishStatus.unlocked.rawValue, "unlocked")
        XCTAssertEqual(WishStatus.completed.rawValue, "completed")
        XCTAssertEqual(WishStatus.paused.rawValue, "paused")
        XCTAssertEqual(WishStatus.archived.rawValue, "archived")
    }

    func testConditionTypeRawValues() {
        XCTAssertEqual(ConditionType.streak.rawValue, "streak")
        XCTAssertEqual(ConditionType.count.rawValue, "count")
        XCTAssertEqual(ConditionType.duration.rawValue, "duration")
        XCTAssertEqual(ConditionType.amount.rawValue, "amount")
        XCTAssertEqual(ConditionType.checkpoint.rawValue, "checkpoint")
        XCTAssertEqual(ConditionType.custom.rawValue, "custom")
    }

    func testAmountDirectionRawValues() {
        XCTAssertEqual(AmountDirection.income.rawValue, "income")
        XCTAssertEqual(AmountDirection.saving.rawValue, "saving")
        XCTAssertEqual(AmountDirection.other.rawValue, "other")
    }

    func testProgressUnitRawValues() {
        XCTAssertEqual(ProgressUnit.times.rawValue, "times")
        XCTAssertEqual(ProgressUnit.days.rawValue, "days")
        XCTAssertEqual(ProgressUnit.hours.rawValue, "hours")
        XCTAssertEqual(ProgressUnit.minutes.rawValue, "minutes")
        XCTAssertEqual(ProgressUnit.yuan.rawValue, "yuan")
        XCTAssertEqual(ProgressUnit.custom.rawValue, "custom")
    }

    func testStatusTerminalStates() {
        XCTAssertFalse(WishStatus.active.isTerminal)
        XCTAssertFalse(WishStatus.unlocked.isTerminal)
        XCTAssertFalse(WishStatus.paused.isTerminal)
        XCTAssertTrue(WishStatus.completed.isTerminal)
        XCTAssertTrue(WishStatus.archived.isTerminal)
    }
}
