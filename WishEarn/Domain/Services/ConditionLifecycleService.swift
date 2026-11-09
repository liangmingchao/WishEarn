import Foundation

@MainActor
protocol ConditionLifecycleServicing {
    func createCondition(_ draft: ConditionDraft) throws -> Condition
    func updateCondition(_ condition: Condition) throws
    func delete(conditionID: UUID) throws
    func reorder(_ conditions: [Condition]) throws
}

@MainActor
final class ConditionLifecycleService: ConditionLifecycleServicing {
    private let wishRepository: WishRepository
    private let conditionRepository: ConditionRepository
    private let clock: ClockProviding
    private let unlockService: WishUnlockServicing?

    init(
        wishRepository: WishRepository,
        conditionRepository: ConditionRepository,
        clock: ClockProviding,
        unlockService: WishUnlockServicing? = nil
    ) {
        self.wishRepository = wishRepository
        self.conditionRepository = conditionRepository
        self.clock = clock
        self.unlockService = unlockService
    }

    func createCondition(_ draft: ConditionDraft) throws -> Condition {
        guard try wishRepository.fetch(id: draft.wishID) != nil else {
            throw DomainError.notFound
        }

        let targetValue = draft.type == .checkpoint ? Decimal(1) : draft.targetValue
        if draft.type == .checkpoint, draft.targetValue != 1 {
            throw DomainError.invalidInput("完成型条件的目标值必须为 1。")
        }

        let condition = try Condition(
            wishID: draft.wishID,
            title: draft.title,
            description: draft.description,
            type: draft.type,
            targetValue: targetValue,
            unit: resolvedUnit(for: draft.type, requested: draft.unit),
            amountDirection: draft.amountDirection,
            isRequired: draft.isRequired,
            sortOrder: draft.sortOrder,
            createdAt: clock.now
        )
        try conditionRepository.save(condition)
        evaluateUnlock(for: draft.wishID)
        return condition
    }

    func updateCondition(_ condition: Condition) throws {
        guard let existing = try conditionRepository.fetch(id: condition.id) else {
            throw DomainError.notFound
        }
        guard existing.wishID == condition.wishID else {
            throw DomainError.invalidInput("不能修改条件所属的心愿。")
        }

        try conditionRepository.save(condition)
        evaluateUnlock(for: condition.wishID)
    }

    func delete(conditionID: UUID) throws {
        guard let condition = try conditionRepository.fetch(id: conditionID) else {
            throw DomainError.notFound
        }

        try conditionRepository.delete(id: conditionID)
        evaluateUnlock(for: condition.wishID)
    }

    func reorder(_ conditions: [Condition]) throws {
        for (index, condition) in conditions.enumerated() {
            var updated = condition
            try updated.updateSortOrder(index)
            try conditionRepository.save(updated)
        }
    }

    private func evaluateUnlock(for wishID: UUID) {
        guard let unlockService else { return }

        do {
            _ = try unlockService.evaluateUnlock(wishID: wishID)
        } catch {
            // 条件已保存；解锁评估失败不阻断条件操作，下次记录或条件变更会再次评估。
        }
    }

    private func resolvedUnit(for type: ConditionType, requested: String?) -> String? {
        let trimmed = requested?.trimmingCharacters(in: .whitespacesAndNewlines)

        switch type {
        case .count:
            return "次"
        case .streak:
            return "天"
        case .amount:
            return "元"
        case .duration:
            return trimmed?.isEmpty == false ? trimmed : "小时"
        case .checkpoint:
            return nil
        case .custom:
            return trimmed?.isEmpty == false ? trimmed : nil
        }
    }
}
