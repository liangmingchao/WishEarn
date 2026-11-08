import Foundation

enum ConditionType: String, Codable, CaseIterable, Sendable {
    case streak
    case count
    case duration
    case amount
    case checkpoint
    case custom

    var requiresAmountDirection: Bool {
        self == .amount
    }
}
