import Foundation

struct WishProgressSummary: Equatable {
    let completedConditionCount: Int
    let totalConditionCount: Int

    var ratio: Double {
        guard totalConditionCount > 0 else { return 0 }
        return Double(completedConditionCount) / Double(totalConditionCount)
    }

    var isComplete: Bool {
        totalConditionCount > 0 && completedConditionCount == totalConditionCount
    }

    var text: String {
        "已完成 \(completedConditionCount) / \(totalConditionCount) 项条件"
    }

    var detailText: String {
        "\(completedConditionCount) / \(totalConditionCount) 项条件完成"
    }

    var accessibilityValue: String {
        "已完成 \(completedConditionCount) 项，共 \(totalConditionCount) 项"
    }
}
