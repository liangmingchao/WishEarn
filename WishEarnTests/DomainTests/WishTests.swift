import XCTest
@testable import WishEarn

final class WishTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    func testCreatesValidWish() throws {
        let wish = try Wish(
            title: "  Kindle Paperwhite  ",
            targetPrice: Decimal(string: "1099.00"),
            createdAt: now,
            updatedAt: now
        )

        XCTAssertEqual(wish.title, "Kindle Paperwhite")
        XCTAssertEqual(wish.currencyCode, "CNY")
        XCTAssertEqual(wish.status, .active)
        XCTAssertEqual(wish.targetPrice, Decimal(string: "1099.00"))
    }

    func testRejectsEmptyTitle() {
        XCTAssertThrowsError(try Wish(title: "   ", createdAt: now, updatedAt: now)) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("心愿名称不能为空。"))
        }
    }

    func testRejectsNegativeTargetPrice() {
        XCTAssertThrowsError(
            try Wish(title: "跑鞋", targetPrice: -1, createdAt: now, updatedAt: now)
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("参考价格不能为负数。"))
        }
    }

    func testUpdateDetailsUsesInjectedTimestamp() throws {
        var wish = try Wish(title: "旧名称", createdAt: now, updatedAt: now)
        let later = TestDates.make(year: 2026, month: 11, day: 9)

        try wish.updateDetails(
            title: "新名称",
            description: "更新后的描述",
            imagePath: "wishes/new.png",
            targetPrice: 1299,
            currencyCode: "CNY",
            targetDate: later,
            now: later
        )

        XCTAssertEqual(wish.title, "新名称")
        XCTAssertEqual(wish.description, "更新后的描述")
        XCTAssertEqual(wish.imagePath, "wishes/new.png")
        XCTAssertEqual(wish.targetPrice, 1299)
        XCTAssertEqual(wish.targetDate, later)
        XCTAssertEqual(wish.updatedAt, later)
    }
}
