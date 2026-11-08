import XCTest
@testable import WishEarn

final class ConditionTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    func testCreatesCountCondition() throws {
        let condition = try Condition(
            wishID: wishID,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次",
            sortOrder: 1,
            createdAt: now
        )

        XCTAssertEqual(condition.wishID, wishID)
        XCTAssertEqual(condition.type, .count)
        XCTAssertEqual(condition.targetValue, 20)
        XCTAssertTrue(condition.isRequired)
        XCTAssertNil(condition.amountDirection)
    }

    func testAmountConditionRequiresDirection() {
        XCTAssertThrowsError(
            try Condition(
                wishID: wishID,
                title: "兼职收入",
                type: .amount,
                targetValue: 5000,
                createdAt: now
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("金额条件必须指定金额方向。"))
        }
    }

    func testNonAmountConditionRejectsDirection() {
        XCTAssertThrowsError(
            try Condition(
                wishID: wishID,
                title: "阅读",
                type: .duration,
                targetValue: 30,
                amountDirection: .income,
                createdAt: now
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("只有金额条件可以指定金额方向。"))
        }
    }

    func testRejectsNonPositiveTarget() {
        XCTAssertThrowsError(
            try Condition(
                wishID: wishID,
                title: "阅读",
                type: .duration,
                targetValue: 0,
                createdAt: now
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("条件目标值必须大于 0。"))
        }
    }

    func testRejectsNegativeSortOrder() {
        XCTAssertThrowsError(
            try Condition(
                wishID: wishID,
                title: "阅读",
                type: .duration,
                targetValue: 30,
                sortOrder: -1,
                createdAt: now
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("条件排序值不能为负数。"))
        }
    }
}
