import XCTest
@testable import WishEarn

final class UnlockEventAndPauseTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

    func testCreatesUnlockEvent() throws {
        let event = try UnlockEvent(
            wishID: wishID,
            unlockedAt: now,
            conditionSnapshot: #"{"count":2}"#,
            createdAt: now
        )

        XCTAssertEqual(event.wishID, wishID)
        XCTAssertEqual(event.unlockedAt, now)
        XCTAssertEqual(event.conditionSnapshot, #"{"count":2}"#)
    }

    func testUnlockEventRejectsEmptySnapshot() {
        XCTAssertThrowsError(
            try UnlockEvent(
                wishID: wishID,
                unlockedAt: now,
                conditionSnapshot: "  ",
                createdAt: now
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("解锁时的条件快照不能为空。"))
        }
    }

    func testPausePeriodOpenAndClosed() throws {
        let open = try WishPausePeriod(wishID: wishID, startedAt: now)
        XCTAssertTrue(open.isOpen)
        XCTAssertNil(open.endedAt)

        let later = TestDates.make(year: 2026, month: 11, day: 10)
        let closed = try WishPausePeriod(wishID: wishID, startedAt: now, endedAt: later)
        XCTAssertFalse(closed.isOpen)
        XCTAssertEqual(closed.endedAt, later)
    }

    func testPausePeriodRejectsInvalidInterval() {
        let earlier = TestDates.make(year: 2026, month: 11, day: 7)

        XCTAssertThrowsError(
            try WishPausePeriod(wishID: wishID, startedAt: now, endedAt: earlier)
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("暂停结束时间不能早于开始时间。"))
        }
    }
}
