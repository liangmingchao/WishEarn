import XCTest
@testable import WishEarn

@MainActor
final class TodayViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private func makeClock() -> FixedClock {
        FixedClock(now: now, calendar: TestDates.calendar)
    }

    private struct SUT {
        let viewModel: TodayViewModel
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
    }

    private func makeSUT() -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let viewModel = TodayViewModel(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            clock: makeClock()
        )
        return SUT(
            viewModel: viewModel,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository
        )
    }

    private func makeWish(
        title: String,
        status: WishStatus = .active
    ) throws -> Wish {
        try Wish(
            title: title,
            status: status,
            createdAt: now,
            updatedAt: now
        )
    }

    private func makeCondition(
        wishID: UUID,
        title: String,
        type: ConditionType,
        targetValue: Decimal,
        unit: String?,
        sortOrder: Int = 0
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: title,
            type: type,
            targetValue: targetValue,
            unit: unit,
            sortOrder: sortOrder,
            createdAt: now
        )
    }

    private func makeRecord(
        conditionID: UUID,
        value: Decimal,
        recordedAt: Date
    ) throws -> ProgressRecord {
        try ProgressRecord(
            conditionID: conditionID,
            value: value,
            recordedAt: recordedAt,
            createdAt: recordedAt,
            updatedAt: recordedAt
        )
    }

    func testTodayTextUsesInjectedClock() {
        let sut = makeSUT()

        XCTAssertEqual(sut.viewModel.todayText, "2026年11月8日")
    }

    func testContainerBuildsTodayViewModelWithInjectedClock() {
        let container = AppContainer.preview()

        XCTAssertEqual(container.makeTodayViewModel().todayText, "2026年11月8日")
    }

    func testRouterDefaultsToWishTab() {
        XCTAssertEqual(AppRouter().selectedTab, .wishes)
    }

    func testLoadOnlyIncludesActiveWishes() throws {
        let sut = makeSUT()
        let activeWish = try makeWish(title: "Kindle")
        let pausedWish = try makeWish(title: "跑鞋", status: .paused)
        try sut.wishRepository.save(activeWish)
        try sut.wishRepository.save(pausedWish)

        let count = try makeCondition(
            wishID: activeWish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次"
        )
        let pausedCondition = try makeCondition(
            wishID: pausedWish.id,
            title: "阅读",
            type: .count,
            targetValue: 10,
            unit: "次"
        )
        try sut.conditionRepository.save(count)
        try sut.conditionRepository.save(pausedCondition)

        sut.viewModel.load()

        XCTAssertNil(sut.viewModel.error)
        XCTAssertTrue(sut.viewModel.hasLoaded)
        XCTAssertEqual(sut.viewModel.items.map(\.condition.id), [count.id])
    }

    func testTodaySummaryUsesTodayRecords() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        try sut.wishRepository.save(wish)

        let count = try makeCondition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次"
        )
        try sut.conditionRepository.save(count)

        try sut.progressRepository.save(
            makeRecord(
                conditionID: count.id,
                value: 3,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 8, hour: 8)
            )
        )
        try sut.progressRepository.save(
            makeRecord(
                conditionID: count.id,
                value: 2,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 7, hour: 8)
            )
        )

        sut.viewModel.load()

        let item = try XCTUnwrap(sut.viewModel.items.first)
        XCTAssertEqual(item.summaryText, "今日 3 次")
        XCTAssertFalse(item.isDone)
        XCTAssertTrue(item.canRecord)
    }

    func testStreakTodayDone() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        try sut.wishRepository.save(wish)

        let streak = try makeCondition(
            wishID: wish.id,
            title: "不吃零食",
            type: .streak,
            targetValue: 30,
            unit: "天"
        )
        try sut.conditionRepository.save(streak)
        try sut.progressRepository.save(
            makeRecord(
                conditionID: streak.id,
                value: 1,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 8, hour: 8)
            )
        )

        sut.viewModel.load()

        let item = try XCTUnwrap(sut.viewModel.items.first)
        XCTAssertTrue(item.isDone)
        XCTAssertFalse(item.canRecord)
        XCTAssertEqual(item.summaryText, "今日已打卡")
    }

    func testCheckpointCompletedFromPreviousDay() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        try sut.wishRepository.save(wish)

        let checkpoint = try makeCondition(
            wishID: wish.id,
            title: "完成开源项目",
            type: .checkpoint,
            targetValue: 1,
            unit: nil
        )
        try sut.conditionRepository.save(checkpoint)
        try sut.progressRepository.save(
            makeRecord(
                conditionID: checkpoint.id,
                value: 1,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 7)
            )
        )

        sut.viewModel.load()

        let item = try XCTUnwrap(sut.viewModel.items.first)
        XCTAssertTrue(item.isDone)
        XCTAssertFalse(item.canRecord)
        XCTAssertEqual(item.summaryText, "已完成")
    }

    func testLoadErrorMapsToAppError() {
        let sut = makeSUT()
        sut.wishRepository.error = PersistenceError.fetchFailed("读取失败")

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.error, .persistence(.fetchFailed("读取失败")))
        XCTAssertTrue(sut.viewModel.hasLoaded)
    }

    func testEmptyLoad() {
        let sut = makeSUT()

        sut.viewModel.load()

        XCTAssertTrue(sut.viewModel.items.isEmpty)
        XCTAssertNil(sut.viewModel.error)
    }
}
