import XCTest
@testable import WishEarn

@MainActor
final class AchievementsViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private struct SUT {
        let viewModel: AchievementsViewModel
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
        let imageStorage: MockImageStorageService
    }

    private func makeSUT() -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let pauseRepository = MockWishPausePeriodRepository()
        let imageStorage = MockImageStorageService()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let calculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let progressService = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pauseRepository,
            progressCalculator: calculator
        )
        let viewModel = AchievementsViewModel(
            wishRepository: wishRepository,
            wishProgressService: progressService,
            progressRepository: progressRepository,
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

    private func makeWish(
        title: String,
        status: WishStatus,
        imagePath: String? = nil
    ) throws -> Wish {
        try Wish(
            title: title,
            imagePath: imagePath,
            status: status,
            createdAt: now,
            updatedAt: now
        )
    }

    private func makeCondition(
        wishID: UUID,
        targetValue: Decimal
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: "条件",
            type: .count,
            targetValue: targetValue,
            unit: "次",
            createdAt: now
        )
    }

    private func makeRecord(
        conditionID: UUID,
        value: Decimal
    ) throws -> ProgressRecord {
        try ProgressRecord(
            conditionID: conditionID,
            value: value,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
    }

    func testLoadBuildsStatsAndSections() throws {
        let sut = makeSUT()

        let active = try makeWish(title: "进行中", status: .active)
        let unlocked = try makeWish(
            title: "已解锁",
            status: .unlocked,
            imagePath: "WishImages/unlocked.jpg"
        )
        let completed = try makeWish(title: "已兑现", status: .completed)

        for wish in [active, unlocked, completed] {
            try sut.wishRepository.save(wish)
        }

        let activeCondition = try makeCondition(wishID: active.id, targetValue: 10)
        let unlockedCondition = try makeCondition(wishID: unlocked.id, targetValue: 10)
        let completedCondition = try makeCondition(wishID: completed.id, targetValue: 5)

        for condition in [activeCondition, unlockedCondition, completedCondition] {
            try sut.conditionRepository.save(condition)
        }

        try sut.progressRepository.save(
            makeRecord(conditionID: activeCondition.id, value: 5)
        )
        try sut.progressRepository.save(
            makeRecord(conditionID: unlockedCondition.id, value: 10)
        )
        try sut.progressRepository.save(
            makeRecord(conditionID: completedCondition.id, value: 5)
        )
        sut.imageStorage.storedImages["WishImages/unlocked.jpg"] = Data([1, 2, 3])

        sut.viewModel.load()

        XCTAssertNil(sut.viewModel.error)
        XCTAssertEqual(sut.viewModel.unlockedWishes.map(\.id), [unlocked.id])
        XCTAssertEqual(sut.viewModel.completedWishes.map(\.id), [completed.id])
        XCTAssertEqual(sut.viewModel.completedConditionCount, 2)
        XCTAssertEqual(sut.viewModel.totalRecordCount, 3)
        XCTAssertEqual(
            sut.viewModel.imageData(for: unlocked),
            Data([1, 2, 3])
        )
    }

    func testEmptyLoad() {
        let sut = makeSUT()

        sut.viewModel.load()

        XCTAssertTrue(sut.viewModel.unlockedWishes.isEmpty)
        XCTAssertTrue(sut.viewModel.completedWishes.isEmpty)
        XCTAssertEqual(sut.viewModel.completedConditionCount, 0)
        XCTAssertEqual(sut.viewModel.totalRecordCount, 0)
        XCTAssertNil(sut.viewModel.error)
        XCTAssertTrue(sut.viewModel.hasLoaded)
    }

    func testLoadErrorMapsToAppError() {
        let sut = makeSUT()
        sut.wishRepository.error = PersistenceError.fetchFailed("读取失败")

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.error, .persistence(.fetchFailed("读取失败")))
        XCTAssertTrue(sut.viewModel.hasLoaded)
    }
}
