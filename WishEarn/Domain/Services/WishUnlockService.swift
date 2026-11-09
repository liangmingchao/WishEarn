import Foundation

@MainActor
protocol WishUnlockServicing {
    func evaluateUnlock(wishID: UUID) throws -> UnlockResult
    func recoverUnlockConsistency() throws -> UnlockRecoveryReport
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
        case .active, .paused, .archived:
            break
        }

        let now = clock.now

        // 解锁事件是历史事实；即使条件后来被删除、或被错误地暂停/归档，
        // 也应根据事件恢复心愿的解锁状态，而不是撤销它。
        let events = try unlockEventRepository.fetchEvents(wishID: wishID)
        if let earliestEvent = events.min(by: { $0.unlockedAt < $1.unlockedAt }) {
            wish.restoreUnlockedState(
                unlockedAt: earliestEvent.unlockedAt,
                now: now
            )
            try wishRepository.save(wish)
            return .alreadyUnlocked
        }

        switch wish.status {
        case .paused, .archived:
            return .notEligible
        case .active:
            break
        case .unlocked, .completed:
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

    /// 启动时恢复解锁一致性。
    ///
    /// 只补写心愿状态，不删除、不覆盖、不新建历史事件；新事件只会通过
    /// `evaluateUnlock` 在满足条件时产生。单个心愿失败不会中断其他心愿，
    /// 失败会记录在报告中供调用方观察。
    func recoverUnlockConsistency() throws -> UnlockRecoveryReport {
        let wishes = try wishRepository.fetchAll()
        let events = try unlockEventRepository.fetchAll()
        let eventsByWishID = Dictionary(grouping: events, by: \.wishID)
        let wishIDs = Set(wishes.map(\.id))

        var report = UnlockRecoveryReport()
        report.orphanedEventWishIDs = Self.sortedUnique(
            events.map(\.wishID).filter { !wishIDs.contains($0) }
        )

        for wish in wishes {
            do {
                let wishEvents = eventsByWishID[wish.id] ?? []

                if wishEvents.isEmpty {
                    switch wish.status {
                    case .unlocked, .completed:
                        // 状态不能被静默撤销；缺少事件属于数据异常，只上报。
                        report.missingEventWishIDs.append(wish.id)
                    case .active:
                        if try evaluateUnlock(wishID: wish.id) == .unlocked {
                            report.newlyUnlockedWishIDs.append(wish.id)
                        }
                    case .paused, .archived:
                        break
                    }
                } else {
                    switch wish.status {
                    case .active, .paused, .archived:
                        if try evaluateUnlock(wishID: wish.id) == .alreadyUnlocked {
                            report.restoredWishIDs.append(wish.id)
                        }
                    case .unlocked, .completed:
                        break
                    }
                }
            } catch {
                report.failures.append(
                    UnlockRecoveryFailure(
                        wishID: wish.id,
                        message: Self.message(for: error)
                    )
                )
            }
        }

        report.restoredWishIDs = Self.sortedUnique(report.restoredWishIDs)
        report.newlyUnlockedWishIDs = Self.sortedUnique(report.newlyUnlockedWishIDs)
        report.missingEventWishIDs = Self.sortedUnique(report.missingEventWishIDs)
        report.failures.sort { $0.wishID.uuidString < $1.wishID.uuidString }
        return report
    }

    private struct ConditionSnapshot: Codable {
        let title: String
        let type: String
        let targetValue: String
        let unit: String?
    }

    private static func sortedUnique(_ ids: [UUID]) -> [UUID] {
        Array(Set(ids)).sorted { $0.uuidString < $1.uuidString }
    }

    private static func message(for error: Error) -> String {
        if let localized = error as? LocalizedError,
           let description = localized.errorDescription {
            return description
        }
        return error.localizedDescription
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
