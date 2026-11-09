import Foundation

@MainActor
final class ProgressCalculator {
    private let streakCalculator: StreakCalculator

    init(streakCalculator: StreakCalculator) {
        self.streakCalculator = streakCalculator
    }

    func calculate(
        condition: Condition,
        records: [ProgressRecord],
        pausePeriods: [WishPausePeriod]
    ) -> ProgressSnapshot {
        switch condition.type {
        case .streak:
            let result = streakCalculator.calculate(
                condition: condition,
                records: records,
                pausePeriods: pausePeriods
            )
            return snapshot(
                current: Decimal(result.currentStreak),
                target: condition.targetValue,
                lastRecordedAt: result.lastRecordedAt
            )

        case .checkpoint:
            let isCompleted = !records.isEmpty
            return ProgressSnapshot(
                currentValue: isCompleted ? 1 : 0,
                targetValue: condition.targetValue,
                progressRatio: isCompleted ? 1 : 0,
                isCompleted: isCompleted,
                remainingValue: isCompleted ? 0 : condition.targetValue,
                lastRecordedAt: records.map(\.recordedAt).max()
            )

        case .count, .duration, .amount, .custom:
            let total = records.reduce(Decimal(0)) { $0 + $1.value }
            return snapshot(
                current: max(Decimal(0), total),
                target: condition.targetValue,
                lastRecordedAt: records.map(\.recordedAt).max()
            )
        }
    }

    private func snapshot(
        current: Decimal,
        target: Decimal,
        lastRecordedAt: Date?
    ) -> ProgressSnapshot {
        let isCompleted = current >= target

        let ratio: Double
        if target > 0 {
            let rawRatio = NSDecimalNumber(decimal: current / target).doubleValue
            ratio = min(1, max(0, rawRatio))
        } else {
            ratio = 0
        }

        let remaining = max(Decimal(0), target - current)

        return ProgressSnapshot(
            currentValue: current,
            targetValue: target,
            progressRatio: ratio,
            isCompleted: isCompleted,
            remainingValue: remaining,
            lastRecordedAt: lastRecordedAt
        )
    }
}
