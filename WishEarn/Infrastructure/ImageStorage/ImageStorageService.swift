import Foundation

protocol ImageStorageService {
    func saveImage(data: Data, for wishID: UUID) throws -> String
    func loadImageData(at relativePath: String) throws -> Data?
    func deleteImage(at relativePath: String) throws
}

enum ImageStorageError: Error, Equatable, LocalizedError {
    case invalidImageData
    case encodingFailed
    case directoryUnavailable
    case invalidPath
    case loadFailed(String)
    case saveFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "无法读取所选图片。"
        case .encodingFailed:
            return "图片压缩失败，请换一张图片重试。"
        case .directoryUnavailable:
            return "图片存储目录不可用。"
        case .invalidPath:
            return "图片路径无效。"
        case .loadFailed(let reason):
            return "读取图片失败：\(reason)"
        case .saveFailed(let reason):
            return "保存图片失败：\(reason)"
        case .deleteFailed(let reason):
            return "删除图片失败：\(reason)"
        }
    }
}
