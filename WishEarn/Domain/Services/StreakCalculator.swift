import Foundation

@MainActor
final class StreakCalculator {
    private let clock: ClockProviding

    init(clock: ClockProviding) {
        self.clock = clock
    }

    func calculate(
        condition: Condition,
        records: [ProgressRecord],
        pausePeriods: [WishPausePeriod]
    ) -> StreakResult {
        let calendar = clock.calendar
        let today = calendar.startOfDay(for: clock.now)
        let pausedDays = pausedDays(from: pausePeriods, today: today, calendar: calendar)
        let recordDays = Set(records.map { calendar.startOfDay(for: $0.recordedAt) })
            .subtracting(pausedDays)

        let longestStreak = longestStreak(
            recordDays: recordDays,
            pausedDays: pausedDays,
            calendar: calendar
        )
        let currentStreak = currentStreak(
            recordDays: recordDays,
            pausedDays: pausedDays,
            today: today,
            calendar: calendar
        )

        return StreakResult(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastRecordedAt: records.map(\.recordedAt).max(),
            isCompleted: Decimal(currentStreak) >= condition.targetValue
        )
    }

    private func pausedDays(
        from periods: [WishPausePeriod],
        today: Date,
        calendar: Calendar
    ) -> Set<Date> {
        var days: Set<Date> = []

        for period in periods {
            let start = calendar.startOfDay(for: period.startedAt)
            let end: Date

            if let endedAt = period.endedAt {
                let endDay = calendar.startOfDay(for: endedAt)
                guard let dayBeforeEnd = calendar.date(byAdding: .day, value: -1, to: endDay) else {
                    continue
                }
                end = min(dayBeforeEnd, today)
            } else {
                end = today
            }

            guard start <= end else { continue }

            var day = start
            while day <= end {
                days.insert(day)
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else {
                    break
                }
                day = next
            }
        }

        return days
    }

    private func longestStreak(
        recordDays: Set<Date>,
        pausedDays: Set<Date>,
        calendar: Calendar
    ) -> Int {
        guard let start = recordDays.min(), let end = recordDays.max() else {
            return 0
        }

        var longest = 0
        var run = 0
        var day = start

        while day <= end {
            if pausedDays.contains(day) {
                // 暂停日跳过，既不累计也不中断。
            } else if recordDays.contains(day) {
                run += 1
                longest = max(longest, run)
            } else {
                run = 0
            }

            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else {
                break
            }
            day = next
        }

        return longest
    }

    private func currentStreak(
        recordDays: Set<Date>,
        pausedDays: Set<Date>,
        today: Date,
        calendar: Calendar
    ) -> Int {
        guard let earliestRecordDay = recordDays.min() else {
            return 0
        }

        var day = today

        // 今天尚未打卡不算中断，从昨天开始计算；今天已暂停则从今天开始跳过。
        if !pausedDays.contains(day) && !recordDays.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else {
                return 0
            }
            day = yesterday
        }

        var streak = 0

        while day >= earliestRecordDay {
            if pausedDays.contains(day) {
                // 暂停日跳过，保留暂停前的连续周期。
            } else if recordDays.contains(day) {
                streak += 1
            } else {
                break
            }

            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previous
        }

        return streak
    }
}
