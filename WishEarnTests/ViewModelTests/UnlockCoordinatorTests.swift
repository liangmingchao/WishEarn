import XCTest
@testable import WishEarn

@MainActor
final class UnlockCoordinatorTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000100")!

    private struct SUT {
        let coordinator: UnlockCoordinator
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let imageStorage: MockImageStorageService
    }

    private func makeSUT() -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let imageStorage = MockImageStorageService()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let lifecycleService = WishLifecycleService(
            wishRepository: wishRepository,
            pausePeriodRepository: MockWishPausePeriodRepository(),
            clock: clock
        )
        let coordinator = UnlockCoordinator(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            imageStorage: imageStorage,
            lifecycleService: lifecycleService
        )
        return SUT(
            coordinator: coordinator,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            imageStorage: imageStorage
        )
    }

    private func makeWish(
        status: WishStatus = .unlocked,
        imagePath: String? = nil
    ) throws -> Wish {
        try Wish(
            id: wishID,
            title: "Kindle",
            imagePath: imagePath,
            status: status,
            createdAt: now,
            updatedAt: now
        )
    }

    func testPublishBuildsPresentation() throws {
        let sut = makeSUT()
        let wish = try makeWish(imagePath: "WishImages/a.jpg")
        try sut.wishRepository.save(wish)
        try sut.conditionRepository.save(
            try Condition(
                wishID: wishID,
                title: "健身",
                type: .count,
                targetValue: 10,
                createdAt: now
            )
        )
        sut.imageStorage.storedImages["WishImages/a.jpg"] = Data([1, 2, 3])

        sut.coordinator.publishUnlock(wishID: wishID)

        let presentation = try XCTUnwrap(sut.coordinator.presentation)
        XCTAssertEqual(presentation.wish.id, wishID)
        XCTAssertEqual(presentation.conditionCount, 1)
        XCTAssertEqual(presentation.imageData, Data([1, 2, 3]))
    }

    func testClaimCompletesWishAndDismisses() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        sut.coordinator.publishUnlock(wishID: wishID)

        sut.coordinator.claim()

        XCTAssertNil(sut.coordinator.presentation)
        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .completed)
        XCTAssertEqual(sut.wishRepository.wishes.first?.completedAt, now)
    }

    func testDismissKeepsWishUnlocked() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        sut.coordinator.publishUnlock(wishID: wishID)

        sut.coordinator.dismiss()

        XCTAssertNil(sut.coordinator.presentation)
        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .unlocked)
    }

    func testPublishFailureSetsError() {
        let sut = makeSUT()
        sut.wishRepository.error = PersistenceError.fetchFailed("读取失败")

        sut.coordinator.publishUnlock(wishID: wishID)

        XCTAssertEqual(sut.coordinator.error, .persistence(.fetchFailed("读取失败")))
        XCTAssertNil(sut.coordinator.presentation)
    }

    func testClaimFailureSetsErrorAndKeepsPresentation() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        sut.coordinator.publishUnlock(wishID: wishID)
        sut.wishRepository.error = PersistenceError.saveFailed("保存失败")

        sut.coordinator.claim()

        XCTAssertEqual(sut.coordinator.error, .persistence(.saveFailed("保存失败")))
        XCTAssertNotNil(sut.coordinator.presentation)
    }
}
