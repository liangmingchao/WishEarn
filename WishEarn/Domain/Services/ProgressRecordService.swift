import Foundation

@MainActor
protocol ProgressRecordServicing {
    func createRecord(_ draft: ProgressRecordDraft) throws -> ProgressRecord
    func updateRecord(_ record: ProgressRecord) throws
    func delete(recordID: UUID) throws
    func records(conditionID: UUID) throws -> [ProgressRecord]
}

@MainActor
final class ProgressRecordService: ProgressRecordServicing {
    private let conditionRepository: ConditionRepository
    private let progressRepository: ProgressRepository
    private let clock: ClockProviding
    private let unlockService: WishUnlockServicing?

    init(
        conditionRepository: ConditionRepository,
        progressRepository: ProgressRepository,
        clock: ClockProviding,
        unlockService: WishUnlockServicing? = nil
    ) {
        self.conditionRepository = conditionRepository
        self.progressRepository = progressRepository
        self.clock = clock
        self.unlockService = unlockService
    }

    func createRecord(_ draft: ProgressRecordDraft) throws -> ProgressRecord {
        guard let condition = try conditionRepository.fetch(id: draft.conditionID) else {
            throw DomainError.notFound
        }

        try validate(
            value: draft.value,
            recordedAt: draft.recordedAt,
            condition: condition,
            excludingRecordID: nil
        )

        let now = clock.now
        let record = try ProgressRecord(
            conditionID: condition.id,
            value: draft.value,
            note: draft.note,
            recordedAt: draft.recordedAt,
            createdAt: now,
            updatedAt: now
        )
        try progressRepository.save(record)
        evaluateUnlock(for: condition.wishID)
        return record
    }

    func updateRecord(_ record: ProgressRecord) throws {
        guard let condition = try conditionRepository.fetch(id: record.conditionID) else {
            throw DomainError.notFound
        }

        let existingRecords = try progressRepository.fetchRecords(conditionID: record.conditionID)
        guard existingRecords.contains(where: { $0.id == record.id }) else {
            throw DomainError.notFound
        }

        try validate(
            value: record.value,
            recordedAt: record.recordedAt,
            condition: condition,
            excludingRecordID: record.id
        )

        try progressRepository.save(record)
        evaluateUnlock(for: condition.wishID)
    }

    func delete(recordID: UUID) throws {
        try progressRepository.delete(id: recordID)
    }

    func records(conditionID: UUID) throws -> [ProgressRecord] {
        try progressRepository.fetchRecords(conditionID: conditionID)
    }

    private func validate(
        value: Decimal,
        recordedAt: Date,
        condition: Condition,
        excludingRecordID: UUID?
    ) throws {
        let endOfToday = clock.calendar.date(
            byAdding: .day,
            value: 1,
            to: clock.calendar.startOfDay(for: clock.now)
        ) ?? clock.now

        guard recordedAt < endOfToday else {
            throw DomainError.invalidInput("不能记录未来的行动。")
        }

        switch condition.type {
        case .count, .duration, .custom:
            guard value > 0 else {
                throw DomainError.invalidInput("记录值必须大于 0。")
            }
        case .amount:
            guard value >= 0 else {
                throw DomainError.invalidInput("金额不能为负数。")
            }
        case .streak:
            guard value == 1 else {
                throw DomainError.invalidInput("连续打卡记录值必须为 1。")
            }
            try ensureNoRecordOnSameDay(
                conditionID: condition.id,
                date: recordedAt,
                excludingRecordID: excludingRecordID
            )
        case .checkpoint:
            guard value == 1 else {
                throw DomainError.invalidInput("完成型记录值必须为 1。")
            }
            try ensureNoOtherRecord(
                conditionID: condition.id,
                excludingRecordID: excludingRecordID
            )
        }
    }

    private func ensureNoRecordOnSameDay(
        conditionID: UUID,
        date: Date,
        excludingRecordID: UUID?
    ) throws {
        let records = try progressRepository.fetchRecords(conditionID: conditionID)
        let hasRecordOnSameDay = records.contains { record in
            record.id != excludingRecordID
                && clock.calendar.isDate(record.recordedAt, inSameDayAs: date)
        }

        if hasRecordOnSameDay {
            throw DomainError.invalidInput("同一天只能记录一次。")
        }
    }

    private func ensureNoOtherRecord(
        conditionID: UUID,
        excludingRecordID: UUID?
    ) throws {
        let records = try progressRepository.fetchRecords(conditionID: conditionID)
        if records.contains(where: { $0.id != excludingRecordID }) {
            throw DomainError.invalidInput("该目标已经完成。")
        }
    }

    private func evaluateUnlock(for wishID: UUID) {
        guard let unlockService else { return }

        do {
            _ = try unlockService.evaluateUnlock(wishID: wishID)
        } catch {
            // 记录已保存；解锁评估失败不阻断记录操作，下次记录变更会再次评估。
        }
    }
}
