import Foundation
@testable import WishEarn

@MainActor
final class MockWishRepository: WishRepository {
    var wishes: [Wish] = []
    var error: Error?
    private(set) var fetchAllCallCount = 0

    func fetch(id: UUID) throws -> Wish? {
        if let error { throw error }
        return wishes.first { $0.id == id }
    }

    func fetchAll() throws -> [Wish] {
        fetchAllCallCount += 1
        if let error { throw error }
        return wishes.sorted { $0.createdAt > $1.createdAt }
    }

    func fetch(status: WishStatus) throws -> [Wish] {
        if let error { throw error }
        return wishes
            .filter { $0.status == status }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ wish: Wish) throws {
        if let error { throw error }
        if let index = wishes.firstIndex(where: { $0.id == wish.id }) {
            wishes[index] = wish
        } else {
            wishes.append(wish)
        }
    }

    func delete(id: UUID) throws {
        if let error { throw error }
        wishes.removeAll { $0.id == id }
    }
}

@MainActor
final class MockWishPausePeriodRepository: WishPausePeriodRepository {
    var periods: [WishPausePeriod] = []
    var error: Error?

    func fetchPeriods(wishID: UUID) throws -> [WishPausePeriod] {
        if let error { throw error }
        return periods
            .filter { $0.wishID == wishID }
            .sorted { $0.startedAt < $1.startedAt }
    }

    func save(_ period: WishPausePeriod) throws {
        if let error { throw error }
        if let index = periods.firstIndex(where: { $0.id == period.id }) {
            periods[index] = period
        } else {
            periods.append(period)
        }
    }

    func delete(id: UUID) throws {
        if let error { throw error }
        periods.removeAll { $0.id == id }
    }
}

@MainActor
final class MockUnlockEventRepository: UnlockEventRepository {
    var events: [UnlockEvent] = []
    var error: Error?

    func fetchEvents(wishID: UUID) throws -> [UnlockEvent] {
        if let error { throw error }
        return events
            .filter { $0.wishID == wishID }
            .sorted { $0.unlockedAt > $1.unlockedAt }
    }

    func hasEvent(wishID: UUID) throws -> Bool {
        if let error { throw error }
        return events.contains { $0.wishID == wishID }
    }

    func save(_ event: UnlockEvent) throws {
        if let error { throw error }
        if !events.contains(where: { $0.id == event.id }) {
            events.append(event)
        }
    }
}

@MainActor
final class MockUnlockEventPublisher: UnlockEventPublishing {
    var publishedWishIDs: [UUID] = []

    func publishUnlock(wishID: UUID) {
        publishedWishIDs.append(wishID)
    }
}

@MainActor
final class MockWishUnlockService: WishUnlockServicing {
    var evaluatedWishIDs: [UUID] = []
    var result: UnlockResult = .notEligible
    var error: Error?

    func evaluateUnlock(wishID: UUID) throws -> UnlockResult {
        if let error { throw error }
        evaluatedWishIDs.append(wishID)
        return result
    }
}

@MainActor
final class MockProgressRepository: ProgressRepository {
    var recordsByCondition: [UUID: [ProgressRecord]] = [:]
    var error: Error?

    func fetchRecords(conditionID: UUID) throws -> [ProgressRecord] {
        if let error { throw error }
        return (recordsByCondition[conditionID] ?? [])
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    func save(_ record: ProgressRecord) throws {
        if let error { throw error }
        var records = recordsByCondition[record.conditionID, default: []]
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }
        recordsByCondition[record.conditionID] = records
    }

    func delete(id: UUID) throws {
        if let error { throw error }
        for key in recordsByCondition.keys {
            recordsByCondition[key]?.removeAll { $0.id == id }
        }
    }

    func deleteAll(conditionID: UUID) throws {
        if let error { throw error }
        recordsByCondition[conditionID] = []
    }
}

@MainActor
final class MockConditionRepository: ConditionRepository {
    var conditionsByWish: [UUID: [Condition]] = [:]
    var error: Error?

    func fetch(id: UUID) throws -> Condition? {
        if let error { throw error }
        return conditionsByWish.values
            .flatMap { $0 }
            .first { $0.id == id }
    }

    func fetchConditions(wishID: UUID) throws -> [Condition] {
        if let error { throw error }
        return (conditionsByWish[wishID] ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    func save(_ condition: Condition) throws {
        if let error { throw error }
        var conditions = conditionsByWish[condition.wishID, default: []]
        if let index = conditions.firstIndex(where: { $0.id == condition.id }) {
            conditions[index] = condition
        } else {
            conditions.append(condition)
        }
        conditionsByWish[condition.wishID] = conditions
    }

    func delete(id: UUID) throws {
        if let error { throw error }
        for key in conditionsByWish.keys {
            conditionsByWish[key]?.removeAll { $0.id == id }
        }
    }
}
