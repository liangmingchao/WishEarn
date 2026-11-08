import Foundation

enum PersistenceError: Error, Equatable, LocalizedError {
    case notFound
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
    case migrationFailed(String)
    case containerUnavailable

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "找不到对应的数据。"
        case .fetchFailed(let reason):
            return "读取数据失败：\(reason)"
        case .saveFailed(let reason):
            return "保存数据失败：\(reason)"
        case .deleteFailed(let reason):
            return "删除数据失败：\(reason)"
        case .migrationFailed(let reason):
            return "数据迁移失败：\(reason)"
        case .containerUnavailable:
            return "本地数据库暂时不可用。"
        }
    }
}
