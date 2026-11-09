import XCTest
@testable import WishEarn

@MainActor
final class ProgressRecordServiceTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)
    private let wishID = UUID(uuidString: "00000000-0000-0000-0000-000000000030")!

    private struct SUT {
        let service: ProgressRecordService
        let conditionRepository: MockConditionRepository
        let progressRepository: MockProgressRepository
    }

    private func makeSUT(
        unlockService: WishUnlockServicing? = nil,
        unlockFailureReporter: UnlockFailureReporting? = nil
    ) -> SUT {
        let conditionRepository = MockConditionRepository()
        let progressRepository = MockProgressRepository()
        let service = ProgressRecordService(
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            clock: FixedClock(now: now, calendar: TestDates.calendar),
            unlockService: unlockService,
            unlockFailureReporter: unlockFailureReporter
        )
        return SUT(
            service: service,
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

    private func makeDraft(
        conditionID: UUID,
        value: Decimal = 1,
        note: String? = nil,
        recordedAt: Date? = nil
    ) -> ProgressRecordDraft {
        ProgressRecordDraft(
            conditionID: conditionID,
            value: value,
            note: note,
            recordedAt: recordedAt ?? now
        )
    }

    func testCreateCountRecord() throws {
        let sut = makeSUT()
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)

        let record = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 5, note: "跑步")
        )

        XCTAssertEqual(record.value, 5)
        XCTAssertEqual(record.note, "跑步")
        XCTAssertEqual(record.createdAt, now)
        XCTAssertEqual(
            try sut.progressRepository.fetchRecords(conditionID: condition.id),
            [record]
        )
    }

    func testCreateDurationRecord() throws {
        let sut = makeSUT()
        let condition = try makeCondition(type: .duration, targetValue: 100, unit: "小时")
        try sut.conditionRepository.save(condition)

        let record = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 2)
        )

        XCTAssertEqual(record.value, 2)
    }

    func testCreateAmountRecordAllowsZero() throws {
        let sut = makeSUT()
        let condition = try makeCondition(
            type: .amount,
            targetValue: 5000,
            unit: "元",
            amountDirection: .income
        )
        try sut.conditionRepository.save(condition)

        let record = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 0)
        )

        XCTAssertEqual(record.value, 0)
    }

    func testCreateAmountRejectsNegativeValue() throws {
        let sut = makeSUT()
        let condition = try makeCondition(
            type: .amount,
            targetValue: 5000,
            unit: "元",
            amountDirection: .income
        )
        try sut.conditionRepository.save(condition)

        XCTAssertThrowsError(
            try sut.service.createRecord(makeDraft(conditionID: condition.id, value: -1))
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("金额不能为负数。"))
        }
    }

    func testCreateCountRejectsZero() throws {
        let sut = makeSUT()
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)

        XCTAssertThrowsError(
            try sut.service.createRecord(makeDraft(conditionID: condition.id, value: 0))
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("记录值必须大于 0。"))
        }
    }

    func testCreateStreakRejectsDuplicateSameDay() throws {
        let sut = makeSUT()
        let condition = try makeCondition(type: .streak, targetValue: 30, unit: "天")
        try sut.conditionRepository.save(condition)

        try sut.service.createRecord(
            makeDraft(
                conditionID: condition.id,
                value: 1,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 7, hour: 9)
            )
        )

        XCTAssertThrowsError(
            try sut.service.createRecord(
                makeDraft(
                    conditionID: condition.id,
                    value: 1,
                    recordedAt: TestDates.make(year: 2026, month: 11, day: 7, hour: 18)
                )
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("同一天只能记录一次。"))
        }
    }

    func testCreateStreakAllowsDifferentDays() throws {
        let sut = makeSUT()
        let condition = try makeCondition(type: .streak, targetValue: 30, unit: "天")
        try sut.conditionRepository.save(condition)

        try sut.service.createRecord(
            makeDraft(
                conditionID: condition.id,
                value: 1,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 6)
            )
        )
        try sut.service.createRecord(
            makeDraft(
                conditionID: condition.id,
                value: 1,
                recordedAt: TestDates.make(year: 2026, month: 11, day: 7)
            )
        )

        XCTAssertEqual(
            try sut.progressRepository.fetchRecords(conditionID: condition.id).count,
            2
        )
    }

    func testCreateCheckpointRejectsSecondRecord() throws {
        let sut = makeSUT()
        let condition = try makeCondition(type: .checkpoint, targetValue: 1, unit: nil)
        try sut.conditionRepository.save(condition)

        try sut.service.createRecord(makeDraft(conditionID: condition.id, value: 1))

        XCTAssertThrowsError(
            try sut.service.createRecord(makeDraft(conditionID: condition.id, value: 1))
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("该目标已经完成。"))
        }
    }

    func testCreateCheckpointRejectsNonOneValue() throws {
        let sut = makeSUT()
        let condition = try makeCondition(type: .checkpoint, targetValue: 1, unit: nil)
        try sut.conditionRepository.save(condition)

        XCTAssertThrowsError(
            try sut.service.createRecord(makeDraft(conditionID: condition.id, value: 2))
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("完成型记录值必须为 1。"))
        }
    }

    func testCreateRequiresExistingCondition() {
        let sut = makeSUT()

        XCTAssertThrowsError(
            try sut.service.createRecord(makeDraft(conditionID: UUID()))
        ) { error in
            XCTAssertEqual(error as? DomainError, .notFound)
        }
    }

    func testCreateRejectsFutureRecord() throws {
        let sut = makeSUT()
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)

        let future = TestDates.make(year: 2026, month: 11, day: 9)

        XCTAssertThrowsError(
            try sut.service.createRecord(
                makeDraft(conditionID: condition.id, recordedAt: future)
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("不能记录未来的行动。"))
        }
    }

    func testUpdateRecordValidatesAndSaves() throws {
        let sut = makeSUT()
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        var record = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 3)
        )

        let later = TestDates.make(year: 2026, month: 11, day: 8, hour: 12)
        try record.update(value: 8, note: "修改", recordedAt: later, now: later)
        try sut.service.updateRecord(record)

        XCTAssertEqual(
            try sut.progressRepository.fetchRecords(conditionID: condition.id).first?.value,
            8
        )
    }

    func testUpdateMissingRecordThrows() throws {
        let sut = makeSUT()
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        let record = try ProgressRecord(
            conditionID: condition.id,
            value: 1,
            recordedAt: now,
            createdAt: now,
            updatedAt: now
        )

        XCTAssertThrowsError(try sut.service.updateRecord(record)) { error in
            XCTAssertEqual(error as? DomainError, .notFound)
        }
    }

    func testDeleteRecord() throws {
        let sut = makeSUT()
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)
        let record = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 1)
        )

        try sut.service.delete(recordID: record.id)

        XCTAssertTrue(
            try sut.progressRepository.fetchRecords(conditionID: condition.id).isEmpty
        )
    }

    func testCreateRecordTriggersUnlockEvaluation() throws {
        let unlockService = MockWishUnlockService()
        let sut = makeSUT(unlockService: unlockService)
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)

        _ = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 1)
        )

        XCTAssertEqual(unlockService.evaluatedWishIDs, [wishID])
    }

    func testUnlockEvaluationFailureDoesNotFailRecordCreation() throws {
        let unlockService = MockWishUnlockService()
        unlockService.error = PersistenceError.saveFailed("解锁失败")
        let reporter = MockUnlockFailureReporter()
        let sut = makeSUT(
            unlockService: unlockService,
            unlockFailureReporter: reporter
        )
        let condition = try makeCondition()
        try sut.conditionRepository.save(condition)

        let record = try sut.service.createRecord(
            makeDraft(conditionID: condition.id, value: 1)
        )

        XCTAssertEqual(
            try sut.progressRepository.fetchRecords(conditionID: condition.id),
            [record]
        )
        XCTAssertEqual(reporter.reportedWishIDs, [wishID])
        XCTAssertEqual(
            reporter.reportedMessages,
            ["保存数据失败：解锁失败"]
        )
    }
}
