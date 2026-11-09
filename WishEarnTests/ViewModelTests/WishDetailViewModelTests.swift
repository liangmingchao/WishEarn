import XCTest
@testable import WishEarn

@MainActor
final class WishDetailViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000020")!

    private struct SUT {
        let viewModel: WishDetailViewModel
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
        let imageStorage: MockImageStorageService
    }

    private func makeSUT(
        wish: Wish? = nil,
        conditions: [Condition] = []
    ) throws -> SUT {
        let wishRepository = MockWishRepository()
        let storedWish: Wish
        if let wish {
            storedWish = wish
        } else {
            storedWish = try Wish(
                id: wishID,
                title: "Kindle",
                createdAt: now,
                updatedAt: now
            )
        }
        try wishRepository.save(storedWish)

        let conditionRepository = MockConditionRepository()
        for condition in conditions {
            try conditionRepository.save(condition)
        }

        let progressRepository = MockProgressRepository()
        let pauseRepository = MockWishPausePeriodRepository()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let conditionService = ConditionLifecycleService(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            clock: clock
        )
        let lifecycleService = WishLifecycleService(
            wishRepository: wishRepository,
            pausePeriodRepository: pauseRepository,
            clock: clock
        )
        let progressCalculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let wishProgressService = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pauseRepository,
            progressCalculator: progressCalculator
        )
        let imageStorage = MockImageStorageService()
        let viewModel = WishDetailViewModel(
            wish: storedWish,
            wishRepository: wishRepository,
            conditionLifecycleService: conditionService,
            wishProgressService: wishProgressService,
            lifecycleService: lifecycleService,
            imageStorage: imageStorage
        )
        return SUT(
            viewModel: viewModel,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            imageStorage: imageStorage
        )
    }

    private func makeCondition(
        title: String,
        sortOrder: Int
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: title,
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: sortOrder,
            createdAt: now
        )
    }

    func testLoadFetchesWishAndSortedConditions() throws {
        let first = try makeCondition(title: "第一", sortOrder: 0)
        let second = try makeCondition(title: "第二", sortOrder: 1)
        let sut = try makeSUT(conditions: [second, first])

        sut.viewModel.load()

        XCTAssertNil(sut.viewModel.error)
        XCTAssertEqual(sut.viewModel.wish.id, wishID)
        XCTAssertEqual(sut.viewModel.conditions.map(\.id), [first.id, second.id])
    }

    func testLoadIncludesImageData() throws {
        let wish = try Wish(
            id: wishID,
            title: "Kindle",
            imagePath: "WishImages/a.jpg",
            createdAt: now,
            updatedAt: now
        )
        let sut = try makeSUT(wish: wish)
        sut.imageStorage.storedImages["WishImages/a.jpg"] = Data([1, 2, 3])

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.imageData, Data([1, 2, 3]))
    }

    func testNextSortOrder() throws {
        let first = try makeCondition(title: "第一", sortOrder: 0)
        let second = try makeCondition(title: "第二", sortOrder: 3)
        let sut = try makeSUT(conditions: [first, second])

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.nextSortOrder, 4)
    }

    func testDeleteConditionReloads() throws {
        let condition = try makeCondition(title: "健身", sortOrder: 0)
        let sut = try makeSUT(conditions: [condition])
        sut.viewModel.load()

        sut.viewModel.deleteCondition(condition)

        XCTAssertTrue(sut.viewModel.conditions.isEmpty)
        XCTAssertNil(sut.viewModel.actionError)
    }

    func testDeleteFailureSetsActionError() throws {
        let condition = try makeCondition(title: "健身", sortOrder: 0)
        let sut = try makeSUT(conditions: [condition])
        sut.viewModel.load()
        sut.conditionRepository.error = PersistenceError.deleteFailed("删除失败")

        sut.viewModel.deleteCondition(condition)

        XCTAssertEqual(sut.viewModel.actionError, .persistence(.deleteFailed("删除失败")))
        XCTAssertEqual(sut.viewModel.conditions.count, 1)
    }

    func testMoveConditionsPersistsOrder() throws {
        let first = try makeCondition(title: "第一", sortOrder: 0)
        let second = try makeCondition(title: "第二", sortOrder: 1)
        let third = try makeCondition(title: "第三", sortOrder: 2)
        let sut = try makeSUT(conditions: [first, second, third])
        sut.viewModel.load()

        sut.viewModel.moveConditions(from: IndexSet(integer: 2), to: 0)

        XCTAssertEqual(sut.viewModel.conditions.map(\.title), ["第三", "第一", "第二"])
        let persisted = try sut.conditionRepository.fetchConditions(wishID: wishID)
        XCTAssertEqual(persisted.map(\.title), ["第三", "第一", "第二"])
        XCTAssertEqual(persisted.map(\.sortOrder), [0, 1, 2])
    }

    func testLoadErrorMapsToAppError() throws {
        let sut = try makeSUT()
        sut.wishRepository.error = PersistenceError.fetchFailed("读取失败")

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.error, .persistence(.fetchFailed("读取失败")))
    }

    func testOverallProgressAndConditionSnapshot() throws {
        let completedCondition = try makeCondition(title: "健身", sortOrder: 0)
        let partialCondition = try makeCondition(title: "阅读", sortOrder: 1)
        let sut = try makeSUT(conditions: [completedCondition, partialCondition])
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

        XCTAssertEqual(try XCTUnwrap(sut.viewModel.progress).overallRatio, 0.5, accuracy: 0.0001)
        XCTAssertEqual(sut.viewModel.snapshot(for: partialCondition)?.currentValue, 5)
    }

    func testCompleteUnlockedWish() throws {
        let wish = try Wish(
            id: wishID,
            title: "Kindle",
            status: .unlocked,
            createdAt: now,
            updatedAt: now
        )
        let sut = try makeSUT(wish: wish)
        sut.viewModel.load()

        sut.viewModel.completeWish()

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .completed)
        XCTAssertEqual(sut.wishRepository.wishes.first?.completedAt, now)
        XCTAssertEqual(sut.viewModel.wish.status, .completed)
    }
}
