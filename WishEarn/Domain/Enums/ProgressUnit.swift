import Foundation

enum ProgressUnit: String, Codable, CaseIterable, Sendable {
    case times
    case days
    case hours
    case minutes
    case yuan
    case custom

    var displayName: String {
        switch self {
        case .times: return "次"
        case .days: return "天"
        case .hours: return "小时"
        case .minutes: return "分钟"
        case .yuan: return "元"
        case .custom: return "自定义"
        }
    }
}
