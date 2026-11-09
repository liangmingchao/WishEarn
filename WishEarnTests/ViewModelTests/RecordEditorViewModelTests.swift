import XCTest
@testable import WishEarn

@MainActor
final class RecordEditorViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000040")!

    private struct SUT {
        let viewModel: RecordEditorViewModel
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
    }

    private func makeSUT(
        condition: Condition,
        record: ProgressRecord? = nil
    ) throws -> SUT {
        let conditionRepository = MockConditionRepository()
        try conditionRepository.save(condition)
        let progressRepository = MockProgressRepository()
        if let record {
            try progressRepository.save(record)
        }
        let service = ProgressRecordService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        let viewModel = RecordEditorViewModel(
            condition: condition,
            record: record,
            service: service,
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        return SUT(
            viewModel: viewModel,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository
        )
    }

    private func makeCondition(
        type: ConditionType = .count,
        targetValue: Decimal = 20,
        unit: String? = "次",
        amountDirection: AmountDirection? = nil
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: "条件",
            type: type,
            targetValue: targetValue,
            unit: unit,
            amountDirection: amountDirection,
            createdAt: now
        )
    }

    func testCreateCountRecord() throws {
        let condition = try makeCondition()
        let sut = try makeSUT(condition: condition)
        sut.viewModel.valueText = "5"
        sut.viewModel.noteText = "跑步"

        sut.viewModel.save()

        XCTAssertTrue(sut.viewModel.isSaved)
        let record = try XCTUnwrap(
            sut.progressRepository.fetchRecords(conditionID: condition.id).first
        )
        XCTAssertEqual(record.value, 5)
        XCTAssertEqual(record.note, "跑步")
        XCTAssertEqual(record.createdAt, now)
    }

    func testCreateAmountRecordAllowsZero() throws {
        let condition = try makeCondition(
            type: .amount,
            targetValue: 5000,
            unit: "元",
            amountDirection: .income
        )
        let sut = try makeSUT(condition: condition)
        sut.viewModel.valueText = "0"

        sut.viewModel.save()

        let record = try XCTUnwrap(
            sut.progressRepository.fetchRecords(conditionID: condition.id).first
        )
        XCTAssertEqual(record.value, 0)
    }

    func testStreakRecordUsesOne() throws {
        let condition = try makeCondition(type: .streak, targetValue: 30, unit: "天")
        let sut = try makeSUT(condition: condition)

        sut.viewModel.save()

        let record = try XCTUnwrap(
            sut.progressRepository.fetchRecords(conditionID: condition.id).first
        )
        XCTAssertEqual(record.value, 1)
    }

    func testEditPrefillsAndUpdatesRecord() throws {
        let condition = try makeCondition()
        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 3,
            note: "原始备注",
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        let sut = try makeSUT(condition: condition, record: record)

        XCTAssertTrue(sut.viewModel.isEditing)
        XCTAssertEqual(sut.viewModel.valueText, "3")
        XCTAssertEqual(sut.viewModel.noteText, "原始备注")

        sut.viewModel.valueText = "8"
        sut.viewModel.noteText = "修改"
        sut.viewModel.save()

        let updated = try XCTUnwrap(
            sut.progressRepository.fetchRecords(conditionID: condition.id).first
        )
        XCTAssertEqual(updated.value, 8)
        XCTAssertEqual(updated.note, "修改")
    }

    func testInvalidValueShowsError() throws {
        let condition = try makeCondition()
        let sut = try makeSUT(condition: condition)
        sut.viewModel.valueText = "abc"

        sut.viewModel.save()

        XCTAssertEqual(sut.viewModel.error, .domain(.invalidInput("请输入有效的记录值。")))
        XCTAssertFalse(sut.viewModel.isSaved)
    }

    func testDuplicateStreakErrorMapsToAppError() throws {
        let condition = try makeCondition(type: .streak, targetValue: 30, unit: "天")
        let existing = try ProgressRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )
        let sut = try makeSUT(condition: condition, record: existing)
        let viewModel = RecordEditorViewModel(
            condition: condition,
            record: nil,
            service: ProgressRecordService(
                conditionRepository: sut.conditionRepository,
                progressRepository: sut.progressRepository,
                clock: FixedClock(now: now, calendar: TestDates.calendar)
            ),
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        viewModel.recordedAt = now

        viewModel.save()

        XCTAssertEqual(viewModel.error, .domain(.invalidInput("同一天只能记录一次。")))
    }

    func testRepositoryErrorMapsToAppError() throws {
        let condition = try makeCondition()
        let sut = try makeSUT(condition: condition)
        sut.progressRepository.error = PersistenceError.saveFailed("磁盘已满")
        sut.viewModel.valueText = "5"

        sut.viewModel.save()

        XCTAssertEqual(sut.viewModel.error, .persistence(.saveFailed("磁盘已满")))
    }

    func testValueLabelsForConditionTypes() throws {
        let count = try makeSUT(condition: try makeCondition())
        XCTAssertEqual(count.viewModel.valueLabel, "本次次数")
        XCTAssertTrue(count.viewModel.showsValueField)
        XCTAssertEqual(count.viewModel.conditionTitle, "条件")
        XCTAssertEqual(count.viewModel.conditionSummary, "累计次数 · 20 次")

        let duration = try makeSUT(
            condition: try makeCondition(
                type: .duration,
                targetValue: 100,
                unit: "小时"
            )
        )
        XCTAssertEqual(duration.viewModel.valueLabel, "本次时长（小时）")

        let amount = try makeSUT(
            condition: try makeCondition(
                type: .amount,
                targetValue: 1000,
                unit: "元",
                amountDirection: .income
            )
        )
        XCTAssertEqual(amount.viewModel.valueLabel, "本次金额（元）")
        XCTAssertEqual(amount.viewModel.amountDirectionText, "收入")

        let custom = try makeSUT(
            condition: try makeCondition(
                type: .custom,
                targetValue: 300,
                unit: "页"
            )
        )
        XCTAssertEqual(custom.viewModel.valueLabel, "本次数值（页）")

        let streak = try makeSUT(
            condition: try makeCondition(type: .streak, targetValue: 30, unit: "天")
        )
        XCTAssertEqual(streak.viewModel.valueLabel, "")
        XCTAssertFalse(streak.viewModel.showsValueField)

        let checkpoint = try makeSUT(
            condition: try makeCondition(type: .checkpoint, targetValue: 1, unit: nil)
        )
        XCTAssertEqual(checkpoint.viewModel.valueLabel, "")
        XCTAssertFalse(checkpoint.viewModel.showsValueField)
    }

    func testNegativeAmountShowsError() throws {
        let condition = try makeCondition(
            type: .amount,
            targetValue: 1000,
            unit: "元",
            amountDirection: .income
        )
        let sut = try makeSUT(condition: condition)
        sut.viewModel.valueText = "-1"

        sut.viewModel.save()

        XCTAssertEqual(sut.viewModel.error, .domain(.invalidInput("金额不能为负数。")))
        XCTAssertFalse(sut.viewModel.isSaved)
    }
}
