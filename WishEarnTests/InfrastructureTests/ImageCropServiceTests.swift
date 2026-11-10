import UIKit
import XCTest
@testable import WishEarn

final class ImageCropServiceTests: XCTestCase {
    func testCropProducesRequestedPixelSize() throws {
        let image = makeImage(size: CGSize(width: 100, height: 80))

        let data = try XCTUnwrap(
            ImageCropService.crop(
                image: image,
                to: CGRect(x: 10, y: 20, width: 40, height: 30)
            )
        )
        let cropped = try XCTUnwrap(UIImage(data: data))

        XCTAssertEqual(cropped.size.width, 40, accuracy: 0.5)
        XCTAssertEqual(cropped.size.height, 30, accuracy: 0.5)
    }

    func testCropClampsRectToImageBounds() throws {
        let image = makeImage(size: CGSize(width: 100, height: 80))

        let data = try XCTUnwrap(
            ImageCropService.crop(
                image: image,
                to: CGRect(x: -10, y: -10, width: 50, height: 50)
            )
        )
        let cropped = try XCTUnwrap(UIImage(data: data))

        XCTAssertEqual(cropped.size.width, 40, accuracy: 0.5)
        XCTAssertEqual(cropped.size.height, 40, accuracy: 0.5)
    }

    func testCropRejectsEmptyOrOutOfBoundsRect() {
        let image = makeImage(size: CGSize(width: 100, height: 80))

        XCTAssertNil(
            ImageCropService.crop(
                image: image,
                to: CGRect(x: 10, y: 10, width: 0, height: 20)
            )
        )
        XCTAssertNil(
            ImageCropService.crop(
                image: image,
                to: CGRect(x: 200, y: 200, width: 20, height: 20)
            )
        )
    }

    func testCropUsesOrientationAdjustedSize() throws {
        let base = makeImage(size: CGSize(width: 100, height: 50))
        let cgImage = try XCTUnwrap(base.cgImage)
        let rotated = UIImage(cgImage: cgImage, scale: 1, orientation: .right)

        XCTAssertEqual(rotated.size.width, 50, accuracy: 0.5)
        XCTAssertEqual(rotated.size.height, 100, accuracy: 0.5)

        let data = try XCTUnwrap(
            ImageCropService.crop(
                image: rotated,
                to: CGRect(x: 0, y: 0, width: 25, height: 50)
            )
        )
        let cropped = try XCTUnwrap(UIImage(data: data))

        XCTAssertEqual(cropped.size.width, 25, accuracy: 0.5)
        XCTAssertEqual(cropped.size.height, 50, accuracy: 0.5)
    }

    func testCropCapsLargeOutputPixelDimension() throws {
        let image = makeImage(size: CGSize(width: 3000, height: 1000))

        let data = try XCTUnwrap(
            ImageCropService.crop(
                image: image,
                to: CGRect(x: 0, y: 0, width: 3000, height: 1000)
            )
        )
        let cropped = try XCTUnwrap(UIImage(data: data))

        XCTAssertLessThanOrEqual(
            max(cropped.size.width, cropped.size.height),
            ImageCropService.maximumPixelDimension + 1
        )
    }

    private func makeImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
