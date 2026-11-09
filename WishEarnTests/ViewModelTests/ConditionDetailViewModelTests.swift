import XCTest
@testable import WishEarn

@MainActor
final class ConditionDetailViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000050")!

    private struct SUT {
        let viewModel: ConditionDetailViewModel
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
    }

    private func makeSUT(
        condition: Condition,
        records: [ProgressRecord] = []
    ) throws -> SUT {
        let conditionRepository = MockConditionRepository()
        try conditionRepository.save(condition)
        let progressRepository = MockProgressRepository()
        for record in records {
            try progressRepository.save(record)
        }

        let service = ProgressRecordService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        let viewModel = ConditionDetailViewModel(
            condition: condition,
            service: service
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
        unit: String? = "次"
    ) throws -> Condition {
        try Condition(
            wishID: wishID,
            title: "条件",
            type: type,
            targetValue: targetValue,
            unit: unit,
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

    func testLoadRecordsSortedDescending() throws {
        let condition = try makeCondition()
        let older = try makeRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: TestDates.make(year: 2026, month: 11, day: 7)
        )
        let newer = try makeRecord(
            conditionID: condition.id,
            value: 2,
            recordedAt: TestDates.make(year: 2026, month: 11, day: 8)
        )
        let sut = try makeSUT(condition: condition, records: [older, newer])

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.records.map(\.id), [newer.id, older.id])
    }

    func testCumulativeSummary() throws {
        let condition = try makeCondition()
        let first = try makeRecord(
            conditionID: condition.id,
            value: 3,
            recordedAt: TestDates.make(year: 2026, month: 11, day: 7)
        )
        let second = try makeRecord(
            conditionID: condition.id,
            value: 5,
            recordedAt: TestDates.make(year: 2026, month: 11, day: 8)
        )
        let sut = try makeSUT(condition: condition, records: [first, second])

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.totalValue, 8)
        XCTAssertEqual(sut.viewModel.summaryText, "累计 8 / 20 次")
    }

    func testStreakSummary() throws {
        let condition = try makeCondition(type: .streak, targetValue: 30, unit: "天")
        let first = try makeRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: TestDates.make(year: 2026, month: 11, day: 7)
        )
        let second = try makeRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: TestDates.make(year: 2026, month: 11, day: 8)
        )
        let sut = try makeSUT(condition: condition, records: [first, second])

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.summaryText, "已记录 2 天")
    }

    func testCheckpointSummary() throws {
        let condition = try makeCondition(type: .checkpoint, targetValue: 1, unit: nil)
        let empty = try makeSUT(condition: condition)
        empty.viewModel.load()
        XCTAssertEqual(empty.viewModel.summaryText, "未完成")

        let record = try makeRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: now
        )
        let completed = try makeSUT(condition: condition, records: [record])
        completed.viewModel.load()
        XCTAssertEqual(completed.viewModel.summaryText, "已完成")
    }

    func testDeleteRecordReloads() throws {
        let condition = try makeCondition()
        let record = try makeRecord(conditionID: condition.id, value: 1, recordedAt: now)
        let sut = try makeSUT(condition: condition, records: [record])
        sut.viewModel.load()

        sut.viewModel.deleteRecord(record)

        XCTAssertTrue(sut.viewModel.records.isEmpty)
        XCTAssertNil(sut.viewModel.actionError)
    }

    func testDeleteFailureSetsActionError() throws {
        let condition = try makeCondition()
        let record = try makeRecord(conditionID: condition.id, value: 1, recordedAt: now)
        let sut = try makeSUT(condition: condition, records: [record])
        sut.viewModel.load()
        sut.progressRepository.error = PersistenceError.deleteFailed("删除失败")

        sut.viewModel.deleteRecord(record)

        XCTAssertEqual(sut.viewModel.actionError, .persistence(.deleteFailed("删除失败")))
    }

    func testLoadErrorMapsToAppError() throws {
        let condition = try makeCondition()
        let sut = try makeSUT(condition: condition)
        sut.progressRepository.error = PersistenceError.fetchFailed("读取失败")

        sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.error, .persistence(.fetchFailed("读取失败")))
    }
}
