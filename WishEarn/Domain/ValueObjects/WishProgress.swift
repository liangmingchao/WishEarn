import Foundation

struct ConditionProgress: Identifiable, Equatable, Sendable {
    let condition: Condition
    let snapshot: ProgressSnapshot

    var id: UUID { condition.id }
}

struct WishProgress: Equatable, Sendable {
    let wish: Wish
    let conditions: [ConditionProgress]
    let requiredTotal: Int
    let requiredCompleted: Int

    var overallRatio: Double {
        guard requiredTotal > 0 else { return 0 }
        return Double(requiredCompleted) / Double(requiredTotal)
    }

    var isUnlockable: Bool {
        requiredTotal > 0 && requiredCompleted == requiredTotal
    }
}
