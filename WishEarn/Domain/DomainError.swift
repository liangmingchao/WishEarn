import Foundation

enum DomainError: Error, Equatable, LocalizedError {
    case invalidInput(String)
    case notFound
    case invalidStateTransition(from: String, to: String)
    case alreadyCompleted
    case notUnlockable

    var errorDescription: String? {
        switch self {
        case .invalidInput(let reason):
            return reason
        case .notFound:
            return "数据不存在，可能已被删除。"
        case .invalidStateTransition(let from, let to):
            return "不允许从 \(from) 变更为 \(to)。"
        case .alreadyCompleted:
            return "该心愿已经完成，不能重复操作。"
        case .notUnlockable:
            return "当前条件尚未满足，心愿还不能解锁。"
        }
    }
}
