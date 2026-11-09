import Foundation

struct ProgressSnapshot: Equatable, Sendable {
    let currentValue: Decimal
    let targetValue: Decimal
    let progressRatio: Double
    let isCompleted: Bool
    let remainingValue: Decimal
    let lastRecordedAt: Date?
}
