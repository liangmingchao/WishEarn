import XCTest
@testable import WishEarn

@MainActor
final class ConditionEditorViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!

    private struct SUT {
        let viewModel: ConditionEditorViewModel
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
    }

    private func makeSUT(
        condition: Condition? = nil,
        sortOrder: Int = 0
    ) throws -> SUT {
        let wishRepository = MockWishRepository()
        let wish = try Wish(
            id: wishID,
            title: "Kindle",
            createdAt: now,
            updatedAt: now
        )
        try wishRepository.save(wish)

        let conditionRepository = MockConditionRepository()
        if let condition {
            try conditionRepository.save(condition)
        }

        let service = ConditionLifecycleService(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        let viewModel = ConditionEditorViewModel(
            wishID: wishID,
            lifecycleService: service,
            condition: condition,
            sortOrder: sortOrder
        )
        return SUT(
            viewModel: viewModel,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository
        )
    }

    func testCreateCountCondition() throws {
        let sut = try makeSUT()
        sut.viewModel.title = "健身"
        sut.viewModel.targetText = "20"

        sut.viewModel.save()

        XCTAssertTrue(sut.viewModel.isSaved)
        let condition = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        XCTAssertEqual(condition.title, "健身")
        XCTAssertEqual(condition.type, .count)
        XCTAssertEqual(condition.targetValue, 20)
        XCTAssertEqual(condition.unit, "次")
        XCTAssertEqual(condition.sortOrder, 0)
        XCTAssertEqual(condition.createdAt, now)
    }

    func testCreateCheckpointCondition() throws {
        let sut = try makeSUT()
        sut.viewModel.type = .checkpoint
        sut.viewModel.onTypeChanged()
        sut.viewModel.title = "完成开源项目"

        sut.viewModel.save()

        let condition = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        XCTAssertEqual(condition.type, .checkpoint)
        XCTAssertEqual(condition.targetValue, 1)
        XCTAssertNil(condition.unit)
    }

    func testCreateAmountConditionUsesDirection() throws {
        let sut = try makeSUT()
        sut.viewModel.type = .amount
        sut.viewModel.onTypeChanged()
        sut.viewModel.title = "兼职收入"
        sut.viewModel.targetText = "5000"
        sut.viewModel.amountDirection = .saving

        sut.viewModel.save()

        let condition = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        XCTAssertEqual(condition.unit, "元")
        XCTAssertEqual(condition.amountDirection, .saving)
    }

    func testCreateCustomConditionKeepsUnit() throws {
        let sut = try makeSUT()
        sut.viewModel.type = .custom
        sut.viewModel.onTypeChanged()
        sut.viewModel.title = "阅读页数"
        sut.viewModel.unit = "页"
        sut.viewModel.targetText = "300"

        sut.viewModel.save()

        let condition = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        XCTAssertEqual(condition.unit, "页")
    }

    func testSaveRejectsEmptyTitle() throws {
        let sut = try makeSUT()
        sut.viewModel.targetText = "20"

        sut.viewModel.save()

        XCTAssertEqual(sut.viewModel.error, .domain(.invalidInput("请输入条件名称。")))
        XCTAssertFalse(sut.viewModel.isSaved)
        XCTAssertTrue(
            try sut.conditionRepository.fetchConditions(wishID: wishID).isEmpty
        )
    }

    func testSaveRejectsInvalidTarget() throws {
        let sut = try makeSUT()
        sut.viewModel.title = "健身"
        sut.viewModel.targetText = "abc"

        sut.viewModel.save()

        XCTAssertEqual(sut.viewModel.error, .domain(.invalidInput("目标值必须大于 0。")))
        XCTAssertFalse(sut.viewModel.isSaved)
    }

    func testEditPrefillsAndUpdatesCondition() throws {
        let condition = try Condition(
            wishID: wishID,
            title: "健身",
            type: .count,
            targetValue: 20,
            unit: "次",
            sortOrder: 2,
            createdAt: now
        )
        let sut = try makeSUT(condition: condition)

        XCTAssertTrue(sut.viewModel.isEditing)
        XCTAssertEqual(sut.viewModel.title, "健身")
        XCTAssertEqual(sut.viewModel.targetText, "20")
        XCTAssertEqual(sut.viewModel.unit, "次")

        sut.viewModel.title = "力量训练"
        sut.viewModel.targetText = "30"
        sut.viewModel.save()

        let updated = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        XCTAssertEqual(updated.id, condition.id)
        XCTAssertEqual(updated.title, "力量训练")
        XCTAssertEqual(updated.targetValue, 30)
        XCTAssertEqual(updated.sortOrder, 2)
        XCTAssertEqual(updated.createdAt, now)
    }

    func testTypeChangeNormalizesUnit() throws {
        let sut = try makeSUT()

        sut.viewModel.type = .duration
        sut.viewModel.onTypeChanged()
        XCTAssertEqual(sut.viewModel.unit, "小时")

        sut.viewModel.type = .amount
        sut.viewModel.onTypeChanged()
        XCTAssertEqual(sut.viewModel.unit, "元")

        sut.viewModel.type = .checkpoint
        sut.viewModel.onTypeChanged()
        XCTAssertEqual(sut.viewModel.targetText, "1")
    }

    func testStreakTargetRejectsNonIntegerValues() throws {
        let sut = try makeSUT()
        sut.viewModel.type = .streak
        sut.viewModel.onTypeChanged()
        sut.viewModel.title = "连续坚持"

        for targetText in ["1.5", "2.9", "0", "-1"] {
            sut.viewModel.targetText = targetText
            sut.viewModel.save()

            XCTAssertEqual(
                sut.viewModel.error,
                .domain(.invalidInput("连续坚持的目标值必须为正整数。"))
            )
            XCTAssertFalse(sut.viewModel.isSaved)
        }

        XCTAssertTrue(
            try sut.conditionRepository.fetchConditions(wishID: wishID).isEmpty
        )
    }

    func testStreakTargetAllowsIntegerValue() throws {
        let sut = try makeSUT()
        sut.viewModel.type = .streak
        sut.viewModel.onTypeChanged()
        sut.viewModel.title = "连续坚持"
        sut.viewModel.targetText = "30"

        sut.viewModel.save()

        XCTAssertTrue(sut.viewModel.isSaved)
        let condition = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        XCTAssertEqual(condition.type, .streak)
        XCTAssertEqual(condition.targetValue, 30)
    }

    func testCountTargetAllowsFractionalValue() throws {
        let sut = try makeSUT()
        sut.viewModel.title = "阅读"
        sut.viewModel.targetText = "1.5"

        sut.viewModel.save()

        XCTAssertTrue(sut.viewModel.isSaved)
        let condition = try XCTUnwrap(
            sut.conditionRepository.fetchConditions(wishID: wishID).first
        )
        let expectedTarget = try XCTUnwrap(Decimal(string: "1.5"))
        XCTAssertEqual(condition.type, .count)
        XCTAssertEqual(condition.targetValue, expectedTarget)
    }
}
