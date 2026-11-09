import Foundation

enum AppError: Error, Equatable, Identifiable, LocalizedError {
    case domain(DomainError)
    case persistence(PersistenceError)
    case image(ImageStorageError)
    case unexpected(String)

    var id: String { title + message }

    var title: String {
        switch self {
        case .domain:
            return "无法完成操作"
        case .persistence:
            return "数据保存失败"
        case .image:
            return "图片处理失败"
        case .unexpected:
            return "出了点问题"
        }
    }

    var message: String {
        switch self {
        case .domain(let error):
            return error.errorDescription ?? "操作未完成。"
        case .persistence(let error):
            return error.errorDescription ?? "数据操作未完成。"
        case .image(let error):
            return error.errorDescription ?? "图片操作未完成。"
        case .unexpected(let message):
            return message
        }
    }

    var isRetryable: Bool {
        switch self {
        case .persistence(.saveFailed),
             .persistence(.fetchFailed),
             .persistence(.containerUnavailable),
             .image(.saveFailed):
            return true
        case .domain, .persistence, .image, .unexpected:
            return false
        }
    }

    var errorDescription: String? { message }

    static func wrap(_ error: Error) -> AppError {
        switch error {
        case let appError as AppError:
            return appError
        case let domainError as DomainError:
            return .domain(domainError)
        case let persistenceError as PersistenceError:
            return .persistence(persistenceError)
        case let imageError as ImageStorageError:
            return .image(imageError)
        default:
            return .unexpected(error.localizedDescription)
        }
    }
}
