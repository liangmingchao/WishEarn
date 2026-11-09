import Foundation
@testable import WishEarn

final class MockImageStorageService: ImageStorageService {
    var storedImages: [String: Data] = [:]
    var savedData: Data?
    var savedWishID: UUID?
    var deletedPaths: [String] = []
    var savePath = "WishImages/mock.jpg"
    var error: Error?

    func saveImage(data: Data, for wishID: UUID) throws -> String {
        if let error { throw error }
        savedData = data
        savedWishID = wishID
        storedImages[savePath] = data
        return savePath
    }

    func loadImageData(at relativePath: String) throws -> Data? {
        if let error { throw error }
        return storedImages[relativePath]
    }

    func deleteImage(at relativePath: String) throws {
        if let error { throw error }
        deletedPaths.append(relativePath)
        storedImages[relativePath] = nil
    }
}
