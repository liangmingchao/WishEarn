import XCTest
@testable import WishEarn

final class WishPhotoCropLayoutTests: XCTestCase {
    private let containerSize = CGSize(width: 390, height: 500)
    private let imageSize = CGSize(width: 1_000, height: 1_000)

    func testDefaultCropRectIsTheFullFittedImage() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: imageSize
        )

        XCTAssertEqual(layout.cropRect.minX, 16, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.minY, 71, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.width, 358, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.height, 358, accuracy: 0.001)
    }

    func testCustomCropRectIsPreserved() {
        let custom = CGRect(x: 40, y: 80, width: 200, height: 300)
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: imageSize,
            cropRect: custom
        )

        XCTAssertEqual(layout.cropRect, custom)
    }

    func testTinyCropRectExpandsToMinimumSideWithinImage() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: imageSize,
            cropRect: CGRect(x: 10, y: 80, width: 20, height: 20)
        )

        XCTAssertEqual(
            layout.cropRect.width,
            WishPhotoCropLayout.minimumCropSide,
            accuracy: 0.001
        )
        XCTAssertEqual(
            layout.cropRect.height,
            WishPhotoCropLayout.minimumCropSide,
            accuracy: 0.001
        )
        XCTAssertEqual(layout.cropRect.minX, 16, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.minY, 71, accuracy: 0.001)
    }

    func testResizingBottomRightCornerChangesOnlyThatCorner() {
        let start = CGRect(x: 50, y: 100, width: 200, height: 200)
        let resized = WishPhotoCropLayout.resizedCropRect(
            from: start,
            handle: .bottomRight,
            translation: CGSize(width: -50, height: -50),
            cropBounds: CGRect(x: 16, y: 71, width: 358, height: 358)
        )

        XCTAssertEqual(resized.minX, start.minX, accuracy: 0.001)
        XCTAssertEqual(resized.minY, start.minY, accuracy: 0.001)
        XCTAssertEqual(resized.maxX, start.maxX - 50, accuracy: 0.001)
        XCTAssertEqual(resized.maxY, start.maxY - 50, accuracy: 0.001)
    }

    func testResizingClampsToImageBoundsAndMinimumSide() {
        let bounds = CGRect(x: 16, y: 71, width: 358, height: 358)
        let start = CGRect(x: 50, y: 100, width: 200, height: 200)

        let expanded = WishPhotoCropLayout.resizedCropRect(
            from: start,
            handle: .bottomRight,
            translation: CGSize(width: 1_000, height: 1_000),
            cropBounds: bounds
        )
        XCTAssertEqual(expanded.maxX, bounds.maxX, accuracy: 0.001)
        XCTAssertEqual(expanded.maxY, bounds.maxY, accuracy: 0.001)

        let shrunk = WishPhotoCropLayout.resizedCropRect(
            from: start,
            handle: .bottomRight,
            translation: CGSize(width: -1_000, height: -1_000),
            cropBounds: bounds
        )
        XCTAssertEqual(
            shrunk.width,
            WishPhotoCropLayout.minimumCropSide,
            accuracy: 0.001
        )
        XCTAssertEqual(
            shrunk.height,
            WishPhotoCropLayout.minimumCropSide,
            accuracy: 0.001
        )
        XCTAssertEqual(shrunk.minX, start.minX, accuracy: 0.001)
        XCTAssertEqual(shrunk.minY, start.minY, accuracy: 0.001)
    }

    func testVisibleImageRectUsesCustomCropRect() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: CGSize(width: 358, height: 358),
            cropRect: CGRect(x: 40, y: 80, width: 200, height: 300)
        )

        let visible = layout.visibleImageRect(zoom: 1, offset: .zero)
        XCTAssertEqual(visible.minX, 24, accuracy: 0.001)
        XCTAssertEqual(visible.minY, 9, accuracy: 0.001)
        XCTAssertEqual(visible.width, 200, accuracy: 0.001)
        XCTAssertEqual(visible.height, 300, accuracy: 0.001)
    }

    func testZoomedVisibleRectStaysInsideImageWithExtremeOffset() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: imageSize
        )

        let visible = layout.visibleImageRect(
            zoom: 4,
            offset: CGSize(width: 9_999, height: -9_999)
        )

        XCTAssertGreaterThanOrEqual(visible.minX, 0)
        XCTAssertGreaterThanOrEqual(visible.minY, 0)
        XCTAssertLessThanOrEqual(visible.maxX, 1_000)
        XCTAssertLessThanOrEqual(visible.maxY, 1_000)
        XCTAssertEqual(visible.width, 250, accuracy: 0.001)
        XCTAssertEqual(visible.height, 250, accuracy: 0.001)
    }

    func testOffCenterCropKeepsImageCovered() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: CGSize(width: 358, height: 358),
            cropRect: CGRect(x: 200, y: 80, width: 150, height: 300)
        )

        let clamped = layout.clampedOffset(
            CGSize(width: 9_999, height: 0),
            zoom: 1
        )
        XCTAssertEqual(clamped.width, 184, accuracy: 0.001)

        let visible = layout.visibleImageRect(zoom: 1, offset: clamped)
        XCTAssertEqual(visible.width, 150, accuracy: 0.001)
        XCTAssertEqual(visible.height, 300, accuracy: 0.001)
    }

    func testTightContainerFitsImageAndDefaultsToFullImage() {
        let layout = WishPhotoCropLayout(
            containerSize: CGSize(width: 390, height: 200),
            imageSize: imageSize
        )

        XCTAssertEqual(layout.cropRect.minX, 111, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.minY, 16, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.width, 168, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.height, 168, accuracy: 0.001)
    }

    func testZeroSizedImageReturnsEmptyGeometry() {
        let layout = WishPhotoCropLayout(
            containerSize: containerSize,
            imageSize: .zero
        )

        XCTAssertEqual(layout.scale(zoom: 1), 0)
        XCTAssertEqual(layout.imageFrameSize(zoom: 1), .zero)
        XCTAssertEqual(layout.visibleImageRect(zoom: 1, offset: .zero), .zero)
    }
}
