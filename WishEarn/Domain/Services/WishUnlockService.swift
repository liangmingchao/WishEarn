import Foundation

@MainActor
protocol WishUnlockServicing {
    func evaluateUnlock(wishID: UUID) throws -> UnlockResult
}

@MainActor
protocol UnlockEventPublishing {
    func publishUnlock(wishID: UUID)
}

@MainActor
final class WishUnlockService: WishUnlockServicing {
    private let wishRepository: WishRepository
    private let unlockEventRepository: UnlockEventRepository
    private let progressService: WishProgressService
    private let clock: ClockProviding
    private let unlockPublisher: UnlockEventPublishing?

    init(
        wishRepository: WishRepository,
        unlockEventRepository: UnlockEventRepository,
        progressService: WishProgressService,
        clock: ClockProviding,
        unlockPublisher: UnlockEventPublishing? = nil
    ) {
        self.wishRepository = wishRepository
        self.unlockEventRepository = unlockEventRepository
        self.progressService = progressService
        self.clock = clock
        self.unlockPublisher = unlockPublisher
    }

    func evaluateUnlock(wishID: UUID) throws -> UnlockResult {
        guard var wish = try wishRepository.fetch(id: wishID) else {
            throw DomainError.notFound
        }

        switch wish.status {
        case .unlocked, .completed:
            return .alreadyUnlocked
        case .paused, .archived:
            return .notEligible
        case .active:
            break
        }

        let now = clock.now

        // 解锁事件是历史事实；即使条件后来被删除，也应恢复心愿的解锁状态。
        if try unlockEventRepository.hasEvent(wishID: wishID) {
            wish.applyStatus(.unlocked, at: now)
            try wishRepository.save(wish)
            return .alreadyUnlocked
        }

        let progress = try progressService.progress(for: wish)
        guard progress.requiredTotal > 0, progress.isUnlockable else {
            return .notEligible
        }

        let snapshot = try makeConditionSnapshot(progress.conditions)
        let event = try UnlockEvent(
            wishID: wishID,
            unlockedAt: now,
            conditionSnapshot: snapshot,
            createdAt: now
        )
        try unlockEventRepository.save(event)

        wish.applyStatus(.unlocked, at: now)

        do {
            try wishRepository.save(wish)
        } catch {
            // 解锁事件已持久化；下次评估会补写心愿状态，避免丢失解锁事实。
            throw error
        }

        unlockPublisher?.publishUnlock(wishID: wishID)
        return .unlocked
    }

    private struct ConditionSnapshot: Codable {
        let title: String
        let type: String
        let targetValue: String
        let unit: String?
    }

    private func makeConditionSnapshot(_ conditions: [ConditionProgress]) throws -> String {
        let items = conditions.map { item in
            ConditionSnapshot(
                title: item.condition.title,
                type: item.condition.type.rawValue,
                targetValue: NSDecimalNumber(decimal: item.condition.targetValue).stringValue,
                unit: item.condition.unit
            )
        }
        let data = try JSONEncoder().encode(items)
        return String(decoding: data, as: UTF8.self)
    }
}
