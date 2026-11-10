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
        let pausePeriodRepository: MockWishPausePeriodRepository
    }

    private func makeSUT() -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let pausePeriodRepository = MockWishPausePeriodRepository()
        let clock = makeClock()
        let progressCalculator = ProgressCalculator(
            streakCalculator: StreakCalculator(clock: clock)
        )
        let wishProgressService = WishProgressService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pausePeriodRepository,
            progressCalculator: progressCalculator
        )
        let viewModel = TodayViewModel(
            wishRepository: wishRepository,
            progressRepository: progressRepository,
            wishProgressService: wishProgressService,
            imageStorage: MockImageStorageService(),
            clock: clock
        )
        return SUT(
            viewModel: viewModel,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            pausePeriodRepository: pausePeriodRepository
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
        amountDirection: AmountDirection? = nil,
        sortOrder: Int = 0
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: title,
            type: type,
            targetValue: targetValue,
            unit: unit,
            amountDirection: amountDirection,
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

        XCTAssertEqual(sut.viewModel.todayText, "星期日 · 11月8日")
    }

    func testContainerBuildsTodayViewModelWithInjectedClock() {
        let container = AppContainer.preview()

        XCTAssertEqual(container.makeTodayViewModel().todayText, "星期日 · 11月8日")
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
        XCTAssertTrue(sut.viewModel.hasAnyWishes)
        XCTAssertEqual(sut.viewModel.actionableItems.map(\.condition.id), [count.id])
        XCTAssertTrue(sut.viewModel.recordedTodayItems.isEmpty)
        XCTAssertTrue(sut.viewModel.completedItems.isEmpty)
    }

    func testCumulativeConditionKeepsCumulativeProgressAndTodayRecord() throws {
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

        let item = try XCTUnwrap(sut.viewModel.actionableItems.first)
        XCTAssertEqual(item.state, .actionable)
        XCTAssertTrue(item.canRecord)
        XCTAssertEqual(item.progressText, "累计 5 / 20 次")
        XCTAssertEqual(item.todayRecordText, "今日已记录 3 次")
    }

    func testStreakRecordedTodayMovesToRecordedToday() throws {
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

        XCTAssertTrue(sut.viewModel.actionableItems.isEmpty)
        XCTAssertEqual(
            sut.viewModel.recordedTodayItems.map(\.condition.id),
            [streak.id]
        )
        let item = try XCTUnwrap(sut.viewModel.recordedTodayItems.first)
        XCTAssertEqual(item.state, .recordedToday)
        XCTAssertFalse(item.canRecord)
        XCTAssertEqual(item.progressText, "连续 1 / 30 天")
        XCTAssertEqual(item.stateText, "已记录")
        XCTAssertNil(item.todayRecordText)
    }

    func testStreakWithoutTodayRecordIsActionable() throws {
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
                recordedAt: TestDates.make(year: 2026, month: 11, day: 7, hour: 8)
            )
        )

        sut.viewModel.load()

        let item = try XCTUnwrap(sut.viewModel.actionableItems.first)
        XCTAssertEqual(item.state, .actionable)
        XCTAssertTrue(item.canRecord)
        XCTAssertEqual(item.progressText, "连续 1 / 30 天")
    }

    func testCheckpointCompletedFromPreviousDayIsCompletedNotRecordedToday() throws {
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

        XCTAssertTrue(sut.viewModel.actionableItems.isEmpty)
        XCTAssertTrue(sut.viewModel.recordedTodayItems.isEmpty)
        let item = try XCTUnwrap(sut.viewModel.completedItems.first)
        XCTAssertEqual(item.state, .completed)
        XCTAssertFalse(item.canRecord)
        XCTAssertEqual(item.progressText, "完成于 11月7日")
        XCTAssertEqual(item.stateText, "已完成")
    }

    func testCheckpointRecordedTodayIsCompletedNotRecordedToday() throws {
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
                recordedAt: TestDates.make(year: 2026, month: 11, day: 8, hour: 8)
            )
        )

        sut.viewModel.load()

        XCTAssertTrue(sut.viewModel.recordedTodayItems.isEmpty)
        let item = try XCTUnwrap(sut.viewModel.completedItems.first)
        XCTAssertEqual(item.state, .completed)
        XCTAssertEqual(item.progressText, "完成于 11月8日")
        XCTAssertEqual(item.stateText, "已完成")
    }

    func testCheckpointWithoutRecordIsActionable() throws {
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

        sut.viewModel.load()

        let item = try XCTUnwrap(sut.viewModel.actionableItems.first)
        XCTAssertEqual(item.state, .actionable)
        XCTAssertTrue(item.canRecord)
        XCTAssertEqual(item.progressText, "完成一次即可达成")
    }

    func testCumulativeTypesRemainActionableWithTodayRecords() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        try sut.wishRepository.save(wish)

        let count = try makeCondition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次",
            sortOrder: 0
        )
        let duration = try makeCondition(
            wishID: wish.id,
            title: "阅读",
            type: .duration,
            targetValue: 30,
            unit: "小时",
            sortOrder: 1
        )
        let amount = try makeCondition(
            wishID: wish.id,
            title: "存钱",
            type: .amount,
            targetValue: 1000,
            unit: "元",
            amountDirection: .saving,
            sortOrder: 2
        )
        let custom = try makeCondition(
            wishID: wish.id,
            title: "练习",
            type: .custom,
            targetValue: 10,
            unit: "组",
            sortOrder: 3
        )
        for condition in [count, duration, amount, custom] {
            try sut.conditionRepository.save(condition)
        }

        for condition in [count, duration, amount, custom] {
            try sut.progressRepository.save(
                makeRecord(
                    conditionID: condition.id,
                    value: 5,
                    recordedAt: TestDates.make(year: 2026, month: 11, day: 8, hour: 8)
                )
            )
        }

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.actionableItems.count, 4)
        XCTAssertEqual(
            sut.viewModel.actionableItems.map(\.condition.id),
            [count.id, duration.id, amount.id, custom.id]
        )
        XCTAssertTrue(sut.viewModel.actionableItems.allSatisfy(\.canRecord))
        XCTAssertTrue(sut.viewModel.recordedTodayItems.isEmpty)
        XCTAssertTrue(sut.viewModel.completedItems.isEmpty)
    }

    func testCountTargetReachedRemainsActionable() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        try sut.wishRepository.save(wish)

        let count = try makeCondition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 5,
            unit: "次"
        )
        try sut.conditionRepository.save(count)
        try sut.progressRepository.save(
            makeRecord(
                conditionID: count.id,
                value: 5,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 8, hour: 8)
            )
        )

        sut.viewModel.load()

        let item = try XCTUnwrap(sut.viewModel.actionableItems.first)
        XCTAssertEqual(item.progressText, "累计 5 / 5 次")
        XCTAssertTrue(item.snapshot.isCompleted)
        XCTAssertTrue(item.canRecord)
    }

    func testConditionsPreserveViewModelOrder() throws {
        let sut = makeSUT()
        let wish = try makeWish(title: "Kindle")
        try sut.wishRepository.save(wish)

        let third = try makeCondition(
            wishID: wish.id,
            title: "第三",
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: 2
        )
        let first = try makeCondition(
            wishID: wish.id,
            title: "第一",
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: 0
        )
        let second = try makeCondition(
            wishID: wish.id,
            title: "第二",
            type: .count,
            targetValue: 10,
            unit: "次",
            sortOrder: 1
        )
        for condition in [third, first, second] {
            try sut.conditionRepository.save(condition)
        }

        sut.viewModel.load()

        XCTAssertEqual(
            sut.viewModel.actionableItems.map(\.condition.id),
            [first.id, second.id, third.id]
        )
    }

    func testOnlyPausedWishesHasNoTodayContentButKnowsWishesExist() throws {
        let sut = makeSUT()
        let pausedWish = try makeWish(title: "跑鞋", status: .paused)
        try sut.wishRepository.save(pausedWish)
        let condition = try makeCondition(
            wishID: pausedWish.id,
            title: "跑步",
            type: .count,
            targetValue: 20,
            unit: "次"
        )
        try sut.conditionRepository.save(condition)

        sut.viewModel.load()

        XCTAssertTrue(sut.viewModel.hasAnyWishes)
        XCTAssertFalse(sut.viewModel.hasContent)
        XCTAssertTrue(sut.viewModel.actionableItems.isEmpty)
        XCTAssertNil(sut.viewModel.error)
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

        XCTAssertFalse(sut.viewModel.hasAnyWishes)
        XCTAssertFalse(sut.viewModel.hasContent)
        XCTAssertTrue(sut.viewModel.actionableItems.isEmpty)
        XCTAssertTrue(sut.viewModel.recordedTodayItems.isEmpty)
        XCTAssertTrue(sut.viewModel.completedItems.isEmpty)
        XCTAssertNil(sut.viewModel.error)
    }
}
