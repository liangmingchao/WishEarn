import XCTest
@testable import WishEarn

@MainActor
final class StartupRecoveryTests: XCTestCase {
    private let earlier = TestDates.make(year: 2026, month: 11, day: 7)
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    func testStartupRecoveryRepairsWishAndKeepsEvent() throws {
        let modelContainer = try ModelContainerFactory.make(inMemory: true)
        let store = SwiftDataStore(container: modelContainer)
        let container = AppContainer(
            dependencies: AppDependencies(
                clock: FixedClock(now: now, calendar: TestDates.calendar)
            ),
            store: store,
            imageStorageService: MockImageStorageService()
        )

        let wish = try Wish(
            title: "Kindle",
            createdAt: earlier,
            updatedAt: earlier
        )
        try container.wishRepository.save(wish)
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: earlier,
            conditionSnapshot: #"{"count":1}"#,
            createdAt: earlier
        )
        try container.unlockEventRepository.save(event)

        container.performStartupRecovery()

        XCTAssertEqual(
            container.startupRecoveryReport?.restoredWishIDs,
            [wish.id]
        )
        let repaired = try XCTUnwrap(
            container.wishRepository.fetch(id: wish.id)
        )
        XCTAssertEqual(repaired.status, .unlocked)
        XCTAssertEqual(repaired.unlockedAt, earlier)
        XCTAssertEqual(
            try container.unlockEventRepository.fetchAll(),
            [event]
        )
    }

    func testStartupRecoveryPersistsRepairAcrossStoreRecreation() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer {
            do {
                try FileManager.default.removeItem(at: directory)
            } catch {
                // 临时目录清理失败不影响测试结果。
            }
        }

        let storeURL = directory.appendingPathComponent("WishEarn.store")
        let dependencies = AppDependencies(
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        let wish = try Wish(
            title: "Kindle",
            createdAt: earlier,
            updatedAt: earlier
        )
        let event = try UnlockEvent(
            wishID: wish.id,
            unlockedAt: earlier,
            conditionSnapshot: #"{"count":1}"#,
            createdAt: earlier
        )

        do {
            let modelContainer = try ModelContainerFactory.make(storeURL: storeURL)
            let store = SwiftDataStore(container: modelContainer)
            let container = AppContainer(
                dependencies: dependencies,
                store: store,
                imageStorageService: MockImageStorageService()
            )
            try container.wishRepository.save(wish)
            try container.unlockEventRepository.save(event)
        }

        let reopenedModelContainer = try ModelContainerFactory.make(storeURL: storeURL)
        let reopenedStore = SwiftDataStore(container: reopenedModelContainer)
        let reopenedContainer = AppContainer(
            dependencies: dependencies,
            store: reopenedStore,
            imageStorageService: MockImageStorageService()
        )

        reopenedContainer.performStartupRecovery()

        XCTAssertEqual(
            reopenedContainer.startupRecoveryReport?.restoredWishIDs,
            [wish.id]
        )
        let repaired = try XCTUnwrap(
            reopenedContainer.wishRepository.fetch(id: wish.id)
        )
        XCTAssertEqual(repaired.status, .unlocked)
        XCTAssertEqual(repaired.unlockedAt, earlier)
        XCTAssertEqual(
            try reopenedContainer.unlockEventRepository.fetchAll(),
            [event]
        )
    }

    func testStartupRecoveryReportIsIdempotent() throws {
        let modelContainer = try ModelContainerFactory.make(inMemory: true)
        let store = SwiftDataStore(container: modelContainer)
        let container = AppContainer(
            dependencies: AppDependencies(
                clock: FixedClock(now: now, calendar: TestDates.calendar)
            ),
            store: store,
            imageStorageService: MockImageStorageService()
        )

        let wish = try Wish(
            title: "Kindle",
            createdAt: earlier,
            updatedAt: earlier
        )
        try container.wishRepository.save(wish)
        try container.unlockEventRepository.save(
            UnlockEvent(
                wishID: wish.id,
                unlockedAt: earlier,
                conditionSnapshot: #"{"count":1}"#,
                createdAt: earlier
            )
        )

        container.performStartupRecovery()
        XCTAssertEqual(
            container.startupRecoveryReport?.restoredWishIDs,
            [wish.id]
        )

        container.performStartupRecovery()

        XCTAssertEqual(container.startupRecoveryReport, UnlockRecoveryReport())
        XCTAssertEqual(
            try container.unlockEventRepository.fetchAll().count,
            1
        )
        XCTAssertEqual(
            try container.wishRepository.fetch(id: wish.id)?.status,
            .unlocked
        )
    }
}
