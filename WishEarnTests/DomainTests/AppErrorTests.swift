import XCTest
@testable import WishEarn

final class AppErrorTests: XCTestCase {
    func testWrapDomainError() {
        let error = AppError.wrap(DomainError.invalidInput("名称为空"))

        XCTAssertEqual(error, .domain(.invalidInput("名称为空")))
        XCTAssertEqual(error.title, "无法完成操作")
        XCTAssertEqual(error.message, "名称为空")
        XCTAssertFalse(error.isRetryable)
    }

    func testWrapPersistenceError() {
        let error = AppError.wrap(PersistenceError.saveFailed("磁盘已满"))

        XCTAssertEqual(error, .persistence(.saveFailed("磁盘已满")))
        XCTAssertEqual(error.title, "数据保存失败")
        XCTAssertTrue(error.isRetryable)
    }

    func testWrapUnexpectedError() {
        struct TestError: LocalizedError {
            var errorDescription: String? { "未知错误" }
        }

        let error = AppError.wrap(TestError())

        XCTAssertEqual(error, .unexpected("未知错误"))
        XCTAssertEqual(error.title, "出了点问题")
        XCTAssertFalse(error.isRetryable)
    }
}
