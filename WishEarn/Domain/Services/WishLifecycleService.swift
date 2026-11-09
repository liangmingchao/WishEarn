import Foundation

@MainActor
protocol WishLifecycleServicing {
    func createWish(_ wish: Wish) throws
    func updateWish(_ wish: Wish) throws
    func delete(wishID: UUID) throws
    func pause(wishID: UUID) throws
    func resume(wishID: UUID) throws
    func archive(wishID: UUID) throws
    func complete(wishID: UUID) throws
}

@MainActor
final class WishLifecycleService: WishLifecycleServicing {
    private let wishRepository: WishRepository
    private let pausePeriodRepository: WishPausePeriodRepository
    private let clock: ClockProviding

    init(
        wishRepository: WishRepository,
        pausePeriodRepository: WishPausePeriodRepository,
        clock: ClockProviding
    ) {
        self.wishRepository = wishRepository
        self.pausePeriodRepository = pausePeriodRepository
        self.clock = clock
    }

    func createWish(_ wish: Wish) throws {
        guard wish.status == .active else {
            throw DomainError.invalidInput("新心愿必须处于进行中状态。")
        }
        try wishRepository.save(wish)
    }

    func updateWish(_ wish: Wish) throws {
        guard try wishRepository.fetch(id: wish.id) != nil else {
            throw DomainError.notFound
        }
        try wishRepository.save(wish)
    }

    func delete(wishID: UUID) throws {
        try wishRepository.delete(id: wishID)
    }

    func pause(wishID: UUID) throws {
        guard var wish = try wishRepository.fetch(id: wishID) else {
            throw DomainError.notFound
        }
        guard wish.status == .active else {
            throw DomainError.invalidStateTransition(
                from: wish.status.rawValue,
                to: WishStatus.paused.rawValue
            )
        }

        let now = clock.now
        let period = try WishPausePeriod(wishID: wishID, startedAt: now)
        try pausePeriodRepository.save(period)

        wish.applyStatus(.paused, at: now)

        do {
            try wishRepository.save(wish)
        } catch {
            do {
                try pausePeriodRepository.delete(id: period.id)
            } catch {
                // 回滚暂停区间失败时保留主错误；孤立区间可由后续清理流程处理。
            }
            throw error
        }
    }

    func resume(wishID: UUID) throws {
        guard var wish = try wishRepository.fetch(id: wishID) else {
            throw DomainError.notFound
        }
        guard wish.status == .paused else {
            throw DomainError.invalidStateTransition(
                from: wish.status.rawValue,
                to: WishStatus.active.rawValue
            )
        }

        let periods = try pausePeriodRepository.fetchPeriods(wishID: wishID)
        let openPeriods = periods.filter(\.isOpen)
        guard !openPeriods.isEmpty else {
            throw DomainError.invalidInput("暂停记录缺失，无法恢复心愿。")
        }

        let now = clock.now
        var closedPeriods: [WishPausePeriod] = []

        for period in openPeriods {
            let closed = try WishPausePeriod(
                id: period.id,
                wishID: wishID,
                startedAt: period.startedAt,
                endedAt: now
            )
            try pausePeriodRepository.save(closed)
            closedPeriods.append(period)
        }

        wish.applyStatus(.active, at: now)

        do {
            try wishRepository.save(wish)
        } catch {
            for period in closedPeriods {
                do {
                    try pausePeriodRepository.save(period)
                } catch {
                    // 回滚暂停区间失败时保留主错误；孤立区间可由后续清理流程处理。
                }
            }
            throw error
        }
    }

    func archive(wishID: UUID) throws {
        guard var wish = try wishRepository.fetch(id: wishID) else {
            throw DomainError.notFound
        }
        guard wish.status == .active || wish.status == .paused else {
            throw DomainError.invalidStateTransition(
                from: wish.status.rawValue,
                to: WishStatus.archived.rawValue
            )
        }

        let now = clock.now
        wish.applyStatus(.archived, at: now)
        try wishRepository.save(wish)

        let periods = try pausePeriodRepository.fetchPeriods(wishID: wishID)
        for period in periods where period.isOpen {
            let closed = try WishPausePeriod(
                id: period.id,
                wishID: wishID,
                startedAt: period.startedAt,
                endedAt: now
            )
            try pausePeriodRepository.save(closed)
        }
    }

    func complete(wishID: UUID) throws {
        guard var wish = try wishRepository.fetch(id: wishID) else {
            throw DomainError.notFound
        }
        guard wish.status == .unlocked else {
            throw DomainError.invalidStateTransition(
                from: wish.status.rawValue,
                to: WishStatus.completed.rawValue
            )
        }

        wish.applyStatus(.completed, at: clock.now)
        try wishRepository.save(wish)
    }
}
