import Foundation

enum WishFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case unlocked
    case completed
    case paused

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .active: return "进行中"
        case .unlocked: return "已解锁"
        case .completed: return "已兑现"
        case .paused: return "已暂停"
        }
    }

    func matches(_ wish: Wish) -> Bool {
        switch self {
        case .all:
            return true
        case .active:
            return wish.status == .active
        case .unlocked:
            return wish.status == .unlocked
        case .completed:
            return wish.status == .completed
        case .paused:
            return wish.status == .paused
        }
    }
}
