import Foundation
import Observation

struct TodayConditionItem: Identifiable {
    let wish: Wish
    let condition: Condition
    let todayRecords: [ProgressRecord]
    let hasAnyRecord: Bool

    var id: UUID { condition.id }

    var todayValue: Decimal {
        todayRecords.reduce(Decimal(0)) { $0 + $1.value }
    }

    var isDone: Bool {
        switch condition.type {
        case .streak:
            return !todayRecords.isEmpty
        case .checkpoint:
            return hasAnyRecord
        case .count, .duration, .amount, .custom:
            return false
        }
    }

    var canRecord: Bool {
        !isDone
    }

    var summaryText: String {
        switch condition.type {
        case .streak:
            return isDone ? "今日已打卡" : "今日待打卡"
        case .checkpoint:
            return hasAnyRecord ? "已完成" : "待完成"
        case .count, .duration, .amount, .custom:
            guard !todayRecords.isEmpty else {
                return "今日未记录"
            }
            let value = NSDecimalNumber(decimal: todayValue).stringValue
            let unit = condition.unit.map { " \($0)" } ?? ""
            return "今日 \(value)\(unit)"
        }
    }
}

@MainActor
@Observable
final class TodayViewModel {
    private let wishRepository: WishRepository
    private let conditionRepository: ConditionRepository
    private let progressRepository: ProgressRepository
    private let clock: ClockProviding

    private(set) var items: [TodayConditionItem] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var error: AppError?

    init(
        wishRepository: WishRepository,
        conditionRepository: ConditionRepository,
        progressRepository: ProgressRepository,
        clock: ClockProviding
    ) {
        self.wishRepository = wishRepository
        self.conditionRepository = conditionRepository
        self.progressRepository = progressRepository
        self.clock = clock
    }

    var todayText: String {
        clock.now.formatted(
            Date.FormatStyle(
                date: .long,
                time: .omitted,
                locale: Locale(identifier: "zh_CN"),
                calendar: clock.calendar,
                timeZone: clock.calendar.timeZone
            )
        )
    }

    func load() {
        isLoading = true
        error = nil

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let activeWishes = try wishRepository.fetchAll().filter { $0.status == .active }
            var loadedItems: [TodayConditionItem] = []

            for wish in activeWishes {
                let conditions = try conditionRepository.fetchConditions(wishID: wish.id)
                for condition in conditions {
                    let records = try progressRepository.fetchRecords(conditionID: condition.id)
                    let todayRecords = records.filter {
                        clock.calendar.isDate($0.recordedAt, inSameDayAs: clock.now)
                    }
                    loadedItems.append(
                        TodayConditionItem(
                            wish: wish,
                            condition: condition,
                            todayRecords: todayRecords,
                            hasAnyRecord: !records.isEmpty
                        )
                    )
                }
            }

            items = loadedItems
        } catch {
            self.error = AppError.wrap(error)
        }
    }
}
