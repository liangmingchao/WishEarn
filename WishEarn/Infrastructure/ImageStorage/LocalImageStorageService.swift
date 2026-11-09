import Foundation
import UIKit

final class LocalImageStorageService: ImageStorageService {
    static let directoryName = "WishImages"

    private let baseDirectory: URL
    private let fileManager: FileManager
    private let maxDimension: CGFloat

    init(
        baseDirectory: URL? = nil,
        fileManager: FileManager = .default,
        maxDimension: CGFloat = 1600
    ) {
        self.fileManager = fileManager
        self.maxDimension = maxDimension

        if let baseDirectory {
            self.baseDirectory = baseDirectory
        } else {
            let applicationSupport = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? fileManager.temporaryDirectory
            self.baseDirectory = applicationSupport
                .appendingPathComponent(Self.directoryName, isDirectory: true)
        }
    }

    func saveImage(data: Data, for wishID: UUID) throws -> String {
        guard let image = UIImage(data: data) else {
            throw ImageStorageError.invalidImageData
        }

        let resized = image.resized(maxDimension: maxDimension)
        guard let jpegData = resized.jpegData(compressionQuality: 0.8) else {
            throw ImageStorageError.encodingFailed
        }

        try ensureDirectory()

        let filename = "\(wishID.uuidString).jpg"
        let url = baseDirectory.appendingPathComponent(filename, isDirectory: false)

        do {
            try jpegData.write(to: url, options: .atomic)
        } catch {
            throw ImageStorageError.saveFailed(error.localizedDescription)
        }

        return "\(Self.directoryName)/\(filename)"
    }

    func loadImageData(at relativePath: String) throws -> Data? {
        let url = try url(for: relativePath)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw ImageStorageError.loadFailed(error.localizedDescription)
        }
    }

    func deleteImage(at relativePath: String) throws {
        let url = try url(for: relativePath)
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw ImageStorageError.deleteFailed(error.localizedDescription)
        }
    }

    private func url(for relativePath: String) throws -> URL {
        let components = relativePath.split(separator: "/", omittingEmptySubsequences: true)
        guard components.count == 2,
              components[0] == Self.directoryName,
              !relativePath.contains("..") else {
            throw ImageStorageError.invalidPath
        }
        return baseDirectory.appendingPathComponent(String(components[1]), isDirectory: false)
    }

    private func ensureDirectory() throws {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: baseDirectory.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else {
                throw ImageStorageError.directoryUnavailable
            }
            return
        }

        do {
            try fileManager.createDirectory(
                at: baseDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            throw ImageStorageError.directoryUnavailable
        }
    }
}
