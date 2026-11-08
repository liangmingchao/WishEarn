import Foundation

enum WishStatus: String, Codable, CaseIterable, Sendable {
    case active
    case unlocked
    case completed
    case paused
    case archived

    var isTerminal: Bool {
        self == .completed || self == .archived
    }
}
