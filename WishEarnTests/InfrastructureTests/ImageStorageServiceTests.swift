import UIKit
import XCTest
@testable import WishEarn

@MainActor
final class ImageStorageServiceTests: XCTestCase {
    private var directory: URL!
    private var service: LocalImageStorageService!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        service = LocalImageStorageService(baseDirectory: directory, maxDimension: 100)
    }

    override func tearDownWithError() throws {
        if let directory {
            do {
                try FileManager.default.removeItem(at: directory)
            } catch {
                // 临时目录清理失败不影响测试结果。
            }
        }
    }

    private func makeImageData(size: CGSize) -> Data {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            UIColor.systemOrange.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }

    func testSaveLoadAndDelete() throws {
        let wishID = UUID()
        let data = makeImageData(size: CGSize(width: 200, height: 100))

        let path = try service.saveImage(data: data, for: wishID)

        XCTAssertEqual(path, "WishImages/\(wishID.uuidString).jpg")
        let loadedData = try XCTUnwrap(try service.loadImageData(at: path))
        let image = try XCTUnwrap(UIImage(data: loadedData))
        XCTAssertLessThanOrEqual(max(image.size.width, image.size.height), 100)

        try service.deleteImage(at: path)
        XCTAssertNil(try service.loadImageData(at: path))
    }

    func testSaveRejectsInvalidImageData() {
        XCTAssertThrowsError(try service.saveImage(data: Data([0, 1, 2]), for: UUID())) { error in
            XCTAssertEqual(error as? ImageStorageError, .invalidImageData)
        }
    }

    func testRejectsPathTraversal() {
        XCTAssertThrowsError(try service.loadImageData(at: "../evil.jpg")) { error in
            XCTAssertEqual(error as? ImageStorageError, .invalidPath)
        }
    }

    func testOverwriteReplacesExistingImage() throws {
        let wishID = UUID()
        let first = try service.saveImage(
            data: makeImageData(size: CGSize(width: 20, height: 20)),
            for: wishID
        )
        let firstData = try XCTUnwrap(try service.loadImageData(at: first))

        let second = try service.saveImage(
            data: makeImageData(size: CGSize(width: 40, height: 40)),
            for: wishID
        )
        let secondData = try XCTUnwrap(try service.loadImageData(at: second))

        XCTAssertEqual(first, second)
        XCTAssertNotEqual(firstData, secondData)
    }
}
