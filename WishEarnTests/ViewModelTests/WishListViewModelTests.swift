import XCTest
@testable import WishEarn

@MainActor
final class WishListViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private struct SUT {
        let viewModel: WishListViewModel
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
        let imageStorage: MockImageStorageService
        let pausePeriodRepository: MockWishPausePeriodRepository
    }

    private func makeSUT() -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let imageStorage = MockImageStorageService()
        let pausePeriodRepository = MockWishPausePeriodRepository()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let lifecycleService = WishLifecycleService(
            wishRepository: wishRepository,
            pausePeriodRepository: pausePeriodRepository,
            clock: clock
        )
        let progressCalculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let wishProgressService = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pausePeriodRepository,
            progressCalculator: progressCalculator
        )
        let viewModel = WishListViewModel(
            wishRepository: wishRepository,
            wishProgressService: wishProgressService,
            imageStorage: imageStorage,
            lifecycleService: lifecycleService
        )
        return SUT(
            viewModel: viewModel,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            imageStorage: imageStorage,
            pausePeriodRepository: pausePeriodRepository
        )
    }

    private func makeWish(
        title: String,
        status: WishStatus = .active,
        createdAt: Date? = nil
    ) throws -> Wish {
        try Wish(
            title: title,
            status: status,
            createdAt: createdAt ?? now,
            updatedAt: createdAt ?? now
        )
    }

    func testLoadFetchesWishesAndConditionCounts() throws {
        let sut = makeSUT()
        let active = try makeWish(title: "Kindle")
        let paused = try makeWish(
            title: "跑鞋",
            status: .paused,
            createdAt: now.addingTimeInterval(-60)
        )

        sut.wishRepository.wishes = [paused, active]
        sut.conditionRepository.conditionsByWish = [
            active.id: [
                try Condition(
                    wishID: active.id,
                    title: "健身",
                    type: .count,
                    targetValue: 20,
                    createdAt: now
                )
            ]
        ]

        sut.viewModel.load()

        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.hasLoaded)
        XCTAssertNil(sut.viewModel.error)
        XCTAssertEqual(sut.viewModel.wishes.map(\.id), [active.id, paused.id])
        XCTAssertEqual(sut.viewModel.conditionCount(for: active), 1)
        XCTAssertEqual(sut.viewModel.conditionCount(for: paused), 0)
    }

    func testFilterByStatus() throws {
        let sut = makeSUT()
        let active = try makeWish(title: "进行中")
        let unlocked = try makeWish(title: "已解锁", status: .unlocked)
        let completed = try makeWish(title: "已兑现", status: .completed)
        let paused = try makeWish(title: "已暂停", status: .paused)

        sut.wishRepository.wishes = [active, unlocked, completed, paused]
        sut.viewModel.load()

        sut.viewModel.filter = .active
        XCTAssertEqual(sut.viewModel.filteredWishes.map(\.id), [active.id])

        sut.viewModel.filter = .unlocked
        XCTAssertEqual(sut.viewModel.filteredWishes.map(\.id), [unlocked.id])

        sut.viewModel.filter = .completed
        XCTAssertEqual(sut.viewModel.filteredWishes.map(\.id), [completed.id])

        sut.viewModel.filter = .paused
        XCTAssertEqual(sut.viewModel.filteredWishes.map(\.id), [paused.id])

        sut.viewModel.filter = .all
        XCTAssertEqual(sut.viewModel.filteredWishes.count, 4)
    }

    func testLoadFailureMapsToAppError() {
        let sut = makeSUT()
        sut.wishRepository.error = PersistenceError.fetchFailed("boom")

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.error, .persistence(.fetchFailed("boom")))
        XCTAssertFalse(sut.viewModel.isLoading)
        XCTAssertTrue(sut.viewModel.hasLoaded)
    }

    func testConditionFetchFailureMapsToAppError() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]
        sut.conditionRepository.error = PersistenceError.fetchFailed("conditions")

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.error, .persistence(.fetchFailed("conditions")))
    }

    func testEmptyLoadKeepsEmptyStateAndResetsStaleFilter() {
        let sut = makeSUT()
        sut.viewModel.filter = .paused

        sut.viewModel.load()

        XCTAssertTrue(sut.viewModel.filteredWishes.isEmpty)
        XCTAssertEqual(sut.viewModel.filter, .all)
        XCTAssertNil(sut.viewModel.error)
        XCTAssertTrue(sut.viewModel.hasLoaded)
        XCTAssertEqual(sut.wishRepository.fetchAllCallCount, 1)
    }

    func testLoadIncludesImageData() throws {
        let sut = makeSUT()
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/a.jpg",
            createdAt: now,
            updatedAt: now
        )
        sut.wishRepository.wishes = [wish]
        sut.imageStorage.storedImages["WishImages/a.jpg"] = Data([1, 2, 3])

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.imageData(for: wish), Data([1, 2, 3]))
    }

    func testImageLoadFailureDoesNotFailList() throws {
        let sut = makeSUT()
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/a.jpg",
            createdAt: now,
            updatedAt: now
        )
        sut.wishRepository.wishes = [wish]
        sut.imageStorage.error = ImageStorageError.loadFailed("broken")

        sut.viewModel.load()

        XCTAssertNil(sut.viewModel.error)
        XCTAssertNil(sut.viewModel.imageData(for: wish))
        XCTAssertEqual(sut.viewModel.wishes, [wish])
    }

    func testDeleteRemovesWishAndReloadsList() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]
        sut.viewModel.load()

        sut.viewModel.delete(wish)

        XCTAssertTrue(sut.viewModel.wishes.isEmpty)
        XCTAssertNil(sut.viewModel.actionError)
        XCTAssertEqual(sut.wishRepository.fetchAllCallCount, 2)
    }

    func testDeleteFailureSetsActionError() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]
        sut.viewModel.load()
        sut.wishRepository.error = PersistenceError.deleteFailed("删除失败")

        sut.viewModel.delete(wish)

        XCTAssertEqual(sut.viewModel.actionError, .persistence(.deleteFailed("删除失败")))
        XCTAssertEqual(sut.viewModel.wishes.count, 1)
    }

    func testPauseAndResumeUpdateStatusAndPeriods() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]
        sut.viewModel.load()

        sut.viewModel.pause(wish)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .paused)
        XCTAssertEqual(sut.viewModel.wishes.first?.status, .paused)
        XCTAssertEqual(sut.pausePeriodRepository.periods.count, 1)
        XCTAssertTrue(sut.pausePeriodRepository.periods[0].isOpen)

        let paused = try XCTUnwrap(sut.wishRepository.wishes.first)
        sut.viewModel.resume(paused)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .active)
        XCTAssertEqual(sut.viewModel.wishes.first?.status, .active)
        XCTAssertNotNil(sut.pausePeriodRepository.periods.first?.endedAt)
    }

    func testPauseFailureSetsActionError() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]
        sut.viewModel.load()
        sut.pausePeriodRepository.error = PersistenceError.saveFailed("暂停失败")

        sut.viewModel.pause(wish)

        XCTAssertEqual(sut.viewModel.actionError, .persistence(.saveFailed("暂停失败")))
        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .active)
    }

    func testCompleteUnlockedWish() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle", status: .unlocked)
        sut.wishRepository.wishes = [wish]
        sut.viewModel.load()

        sut.viewModel.complete(wish)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .completed)
        XCTAssertNotNil(sut.wishRepository.wishes.first?.completedAt)
    }

    func testActiveWishCount() throws {
        let sut = makeSUT()
        sut.wishRepository.wishes = [
            try makeWish(title: "进行中"),
            try makeWish(title: "已暂停", status: .paused)
        ]

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.activeWishCount, 1)
    }

    func testFeaturedWishSelectionPreservesSourceOrderAndFilterBehavior() throws {
        let sut = makeSUT()
        let firstActive = try makeWish(title: "Kindle", createdAt: now)
        let unlocked = try makeWish(
            title: "跑鞋",
            status: .unlocked,
            createdAt: now.addingTimeInterval(-10)
        )
        let secondActive = try makeWish(
            title: "京都",
            createdAt: now.addingTimeInterval(-20)
        )
        let paused = try makeWish(
            title: "相机",
            status: .paused,
            createdAt: now.addingTimeInterval(-30)
        )
        sut.wishRepository.wishes = [paused, secondActive, unlocked, firstActive]

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.filteredWishes.map(\.id), [
            firstActive.id,
            unlocked.id,
            secondActive.id,
            paused.id
        ])
        XCTAssertEqual(sut.viewModel.featuredWish?.id, firstActive.id)
        XCTAssertEqual(sut.viewModel.secondaryWishes.map(\.id), [
            unlocked.id,
            secondActive.id,
            paused.id
        ])

        sut.viewModel.filter = .active
        XCTAssertEqual(sut.viewModel.featuredWish?.id, firstActive.id)
        XCTAssertEqual(sut.viewModel.secondaryWishes.map(\.id), [secondActive.id])

        sut.viewModel.filter = .unlocked
        XCTAssertNil(sut.viewModel.featuredWish)
        XCTAssertEqual(sut.viewModel.secondaryWishes.map(\.id), [unlocked.id])

        sut.viewModel.filter = .paused
        XCTAssertNil(sut.viewModel.featuredWish)
        XCTAssertEqual(sut.viewModel.secondaryWishes.map(\.id), [paused.id])
    }

    func testFeaturedWishSkipsNewerNonActiveWishes() throws {
        let sut = makeSUT()
        let paused = try makeWish(title: "相机", status: .paused, createdAt: now)
        let active = try makeWish(
            title: "Kindle",
            createdAt: now.addingTimeInterval(-10)
        )
        sut.wishRepository.wishes = [active, paused]

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.filteredWishes.map(\.id), [paused.id, active.id])
        XCTAssertEqual(sut.viewModel.featuredWish?.id, active.id)
        XCTAssertEqual(sut.viewModel.secondaryWishes.map(\.id), [paused.id])
    }

    func testFeaturedWishIsNilWhenNoActiveWishExists() throws {
        let sut = makeSUT()
        let unlocked = try makeWish(title: "跑鞋", status: .unlocked, createdAt: now)
        let completed = try makeWish(
            title: "相机",
            status: .completed,
            createdAt: now.addingTimeInterval(-10)
        )
        sut.wishRepository.wishes = [completed, unlocked]

        sut.viewModel.load()

        XCTAssertNil(sut.viewModel.featuredWish)
        XCTAssertEqual(
            sut.viewModel.secondaryWishes.map(\.id),
            [unlocked.id, completed.id]
        )
    }

    func testProgressSummaryUsesRequiredConditionsOnly() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]

        let required = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: 0,
            createdAt: now
        )
        let optional = try Condition(
            wishID: wish.id,
            title: "阅读",
            type: .count,
            targetValue: 10,
            unit: "次",
            isRequired: false,
            sortOrder: 1,
            createdAt: now
        )
        try sut.conditionRepository.save(required)
        try sut.conditionRepository.save(optional)
        try sut.progressRepository.save(
            try ProgressRecord(
                conditionID: required.id,
                value: 10,
                recordedAt: now,
                createdAt: now,
                updatedAt: now
            )
        )
        try sut.progressRepository.save(
            try ProgressRecord(
                conditionID: optional.id,
                value: 10,
                recordedAt: now,
                createdAt: now,
                updatedAt: now
            )
        )

        sut.viewModel.load()

        let summary = try XCTUnwrap(sut.viewModel.progressSummary(for: wish))
        XCTAssertEqual(summary.completedConditionCount, 1)
        XCTAssertEqual(summary.totalConditionCount, 1)
        XCTAssertEqual(summary.ratio, 1, accuracy: 0.0001)
        XCTAssertTrue(summary.isComplete)
        XCTAssertEqual(summary.text, "已完成 1 / 1 项条件")
        XCTAssertEqual(sut.viewModel.conditionCount(for: wish), 2)
    }

    func testProgressSummaryIsNilWithoutRequiredConditions() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]
        try sut.conditionRepository.save(
            try Condition(
                wishID: wish.id,
                title: "阅读",
                type: .count,
                targetValue: 10,
                unit: "次",
                isRequired: false,
                createdAt: now
            )
        )

        sut.viewModel.load()

        XCTAssertNil(sut.viewModel.progressSummary(for: wish))
    }

    func testOverallProgress() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        sut.wishRepository.wishes = [wish]

        let completedCondition = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: 0,
            createdAt: now
        )
        let partialCondition = try Condition(
            wishID: wish.id,
            title: "阅读",
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: 1,
            createdAt: now
        )
        try sut.conditionRepository.save(completedCondition)
        try sut.conditionRepository.save(partialCondition)
        try sut.progressRepository.save(
            try ProgressRecord(
                conditionID: completedCondition.id,
                value: 10,
                recordedAt: now,
                createdAt: now,
                updatedAt: now
            )
        )
        try sut.progressRepository.save(
            try ProgressRecord(
                conditionID: partialCondition.id,
                value: 5,
                recordedAt: now,
                createdAt: now,
                updatedAt: now
            )
        )

        sut.viewModel.load()

        XCTAssertEqual(
            try XCTUnwrap(sut.viewModel.overallProgress(for: wish)),
            0.5,
            accuracy: 0.0001
        )
        XCTAssertEqual(sut.viewModel.conditionCount(for: wish), 2)
    }
}
