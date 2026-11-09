import XCTest
@testable import WishEarn

@MainActor
final class PersistenceTests: XCTestCase {
    func testDataSurvivesContainerRecreation() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        defer {
            do {
                try FileManager.default.removeItem(at: directory)
            } catch {
                // 临时目录清理失败不影响测试结果。
            }
        }

        let storeURL = directory.appendingPathComponent("WishEarn.store")
        let now = TestDates.make(year: 2026, month: 11, day: 8)

        let wish = try Wish(title: "Kindle", createdAt: now, updatedAt: now)
        let condition = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次",
            createdAt: now
        )
        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 5,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )

        do {
            let container = try ModelContainerFactory.make(storeURL: storeURL)
            let store = SwiftDataStore(container: container)
            try SwiftDataWishRepository(store: store).save(wish)
            try SwiftDataConditionRepository(store: store).save(condition)
            try SwiftDataProgressRepository(store: store).save(record)
        }

        let container = try ModelContainerFactory.make(storeURL: storeURL)
        let store = SwiftDataStore(container: container)

        XCTAssertEqual(
            try SwiftDataWishRepository(store: store).fetch(id: wish.id),
            wish
        )
        XCTAssertEqual(
            try SwiftDataConditionRepository(store: store).fetchConditions(wishID: wish.id),
            [condition]
        )
        XCTAssertEqual(
            try SwiftDataProgressRepository(store: store).fetchRecords(conditionID: condition.id),
            [record]
        )
    }
}
