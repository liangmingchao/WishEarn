import Foundation
import Observation

/// How a condition is presented on Today.
///
/// `recordedToday` is intentionally limited to STREAK, the only condition type
/// whose existing recording rule is once per local natural day. CHECKPOINT is
/// completed after its first record regardless of when that record happened, so
/// it belongs to `completed`, never to the “recorded today” group.
enum TodayConditionState: Equatable {
    case actionable
    case recordedToday
    case completed
}

struct TodayConditionItem: Identifiable {
    let wish: Wish
    let condition: Condition
    let snapshot: ProgressSnapshot
    let todayRecords: [ProgressRecord]
    let state: TodayConditionState

    var id: UUID { condition.id }

    var todayValue: Decimal {
        todayRecords.reduce(Decimal(0)) { $0 + $1.value }
    }

    /// Mirrors the existing Today recording semantics. COUNT, DURATION,
    /// AMOUNT, and CUSTOM remain recordable after a same-day record.
    var canRecord: Bool {
        state == .actionable
    }

    var progressText: String {
        switch condition.type {
        case .streak:
            return "连续 \(valueText(snapshot.currentValue)) / \(valueText(snapshot.targetValue))\(unitSuffix)"
        case .checkpoint:
            if snapshot.isCompleted, let completedAt = snapshot.lastRecordedAt {
                return "完成于 \(completedAt.formatted(completionDateStyle))"
            }
            return "完成一次即可达成"
        case .count, .duration, .amount, .custom:
            return "累计 \(valueText(snapshot.currentValue)) / \(valueText(snapshot.targetValue))\(unitSuffix)"
        }
    }

    /// A factual same-day note for cumulative types. It is not a daily quota:
    /// the record button remains available because these types keep accepting
    /// records after the first one today.
    var todayRecordText: String? {
        guard !todayRecords.isEmpty else { return nil }

        switch condition.type {
        case .streak, .checkpoint:
            return nil
        case .count, .duration, .amount, .custom:
            return "今日已记录 \(valueText(todayValue))\(unitSuffix)"
        }
    }

    var stateText: String {
        switch state {
        case .actionable:
            return "记录"
        case .recordedToday:
            return "已记录"
        case .completed:
            return "已完成"
        }
    }

    var accessibilityDescription: String {
        var parts = [wish.title, condition.title, progressText]
        if let todayRecordText {
            parts.append(todayRecordText)
        }
        if state == .recordedToday {
            parts.append("今日已记录")
        }
        if state == .completed {
            parts.append("已完成")
        }
        return parts.joined(separator: "，")
    }

    private var unitSuffix: String {
        condition.unit.map { " \($0)" } ?? ""
    }

    private var completionDateStyle: Date.FormatStyle {
        Date.FormatStyle(
            date: .omitted,
            time: .omitted,
            locale: Locale(identifier: "zh_CN")
        )
        .month(.wide)
        .day()
    }

    private func valueText(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}

@MainActor
@Observable
final class TodayViewModel {
    private let wishRepository: WishRepository
    private let progressRepository: ProgressRepository
    private let wishProgressService: WishProgressService
    private let clock: ClockProviding

    private(set) var actionableItems: [TodayConditionItem] = []
    private(set) var recordedTodayItems: [TodayConditionItem] = []
    private(set) var completedItems: [TodayConditionItem] = []
    private(set) var hasAnyWishes = false
    private(set) var hasLoaded = false
    private(set) var error: AppError?

    init(
        wishRepository: WishRepository,
        progressRepository: ProgressRepository,
        wishProgressService: WishProgressService,
        clock: ClockProviding
    ) {
        self.wishRepository = wishRepository
        self.progressRepository = progressRepository
        self.wishProgressService = wishProgressService
        self.clock = clock
    }

    var hasContent: Bool {
        !actionableItems.isEmpty
            || !recordedTodayItems.isEmpty
            || !completedItems.isEmpty
    }

    var todayText: String {
        let baseStyle = Date.FormatStyle(
            date: .omitted,
            time: .omitted,
            locale: Locale(identifier: "zh_CN"),
            calendar: clock.calendar,
            timeZone: clock.calendar.timeZone
        )
        let weekday = clock.now.formatted(baseStyle.weekday(.wide))
        let monthDay = clock.now.formatted(
            baseStyle.month(.wide).day()
        )
        return "\(weekday) · \(monthDay)"
    }

    func load() {
        error = nil

        defer {
            hasLoaded = true
        }

        do {
            let allWishes = try wishRepository.fetchAll()
            hasAnyWishes = !allWishes.isEmpty
            let activeWishes = allWishes.filter { $0.status == .active }

            var actionable: [TodayConditionItem] = []
            var recordedToday: [TodayConditionItem] = []
            var completed: [TodayConditionItem] = []

            for wish in activeWishes {
                let progress = try wishProgressService.progress(for: wish)

                for conditionProgress in progress.conditions {
                    let condition = conditionProgress.condition
                    let records = try progressRepository.fetchRecords(
                        conditionID: condition.id
                    )
                    let todayRecords = records.filter {
                        clock.calendar.isDate(
                            $0.recordedAt,
                            inSameDayAs: clock.now
                        )
                    }
                    let item = TodayConditionItem(
                        wish: wish,
                        condition: condition,
                        snapshot: conditionProgress.snapshot,
                        todayRecords: todayRecords,
                        state: Self.state(
                            for: condition,
                            snapshot: conditionProgress.snapshot,
                            hasTodayRecord: !todayRecords.isEmpty
                        )
                    )

                    switch item.state {
                    case .actionable:
                        actionable.append(item)
                    case .recordedToday:
                        recordedToday.append(item)
                    case .completed:
                        completed.append(item)
                    }
                }
            }

            actionableItems = actionable
            recordedTodayItems = recordedToday
            completedItems = completed
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    private static func state(
        for condition: Condition,
        snapshot: ProgressSnapshot,
        hasTodayRecord: Bool
    ) -> TodayConditionState {
        switch condition.type {
        case .streak:
            return hasTodayRecord ? .recordedToday : .actionable
        case .checkpoint:
            return snapshot.isCompleted ? .completed : .actionable
        case .count, .duration, .amount, .custom:
            return .actionable
        }
    }
}
