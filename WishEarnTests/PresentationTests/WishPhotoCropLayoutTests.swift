import XCTest
@testable import WishEarn

final class WishPhotoCropLayoutTests: XCTestCase {
    func testCropWindowUses16By10AndCenters() {
        let layout = WishPhotoCropLayout(
            containerSize: CGSize(width: 390, height: 500),
            imageSize: CGSize(width: 1000, height: 1000)
        )

        XCTAssertEqual(layout.cropSize.width, 358, accuracy: 0.001)
        XCTAssertEqual(layout.cropSize.height, 223.75, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.midX, 195, accuracy: 0.001)
        XCTAssertEqual(layout.cropRect.midY, 250, accuracy: 0.001)
    }

    func testSquareImageFillsWidthAndCanPanVerticallyAtBaseZoom() {
        let layout = WishPhotoCropLayout(
            containerSize: CGSize(width: 390, height: 500),
            imageSize: CGSize(width: 1000, height: 1000)
        )

        let visible = layout.visibleImageRect(zoom: 1, offset: .zero)
        XCTAssertEqual(visible.minX, 0, accuracy: 0.001)
        XCTAssertEqual(visible.width, 1000, accuracy: 0.001)
        XCTAssertEqual(visible.minY, 187.5, accuracy: 0.001)
        XCTAssertEqual(visible.height, 625, accuracy: 0.001)

        let clamped = layout.clampedOffset(
            CGSize(width: 1_000, height: 1_000),
            zoom: 1
        )
        XCTAssertEqual(clamped.width, 0, accuracy: 0.001)
        XCTAssertEqual(clamped.height, 67.125, accuracy: 0.001)
    }

    func testZoomedVisibleRectStaysInsideImageEvenWithExtremeOffset() {
        let layout = WishPhotoCropLayout(
            containerSize: CGSize(width: 390, height: 500),
            imageSize: CGSize(width: 1000, height: 1000)
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
        XCTAssertEqual(visible.height, 156.25, accuracy: 0.001)
    }

    func testTightContainerShrinksCropByHeight() {
        let layout = WishPhotoCropLayout(
            containerSize: CGSize(width: 390, height: 200),
            imageSize: CGSize(width: 1000, height: 1000)
        )

        XCTAssertEqual(layout.cropSize.width, 268.8, accuracy: 0.001)
        XCTAssertEqual(layout.cropSize.height, 168, accuracy: 0.001)
    }

    func testZeroSizedImageReturnsEmptyGeometry() {
        let layout = WishPhotoCropLayout(
            containerSize: CGSize(width: 390, height: 500),
            imageSize: .zero
        )

        XCTAssertEqual(layout.scale(zoom: 1), 0)
        XCTAssertEqual(layout.imageFrameSize(zoom: 1), .zero)
        XCTAssertEqual(layout.visibleImageRect(zoom: 1, offset: .zero), .zero)
    }
}
