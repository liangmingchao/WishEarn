import CoreGraphics

/// Geometry for the wish-photo crop screen.
///
/// The crop window uses the Detail hero ratio (16:10). Home still presents the
/// saved image in its own 2:1 frame, so this is a composition aid rather than a
/// promise that every surface will show exactly the same pixels.
struct WishPhotoCropLayout: Equatable {
    static let aspectRatio: CGFloat = 16.0 / 10.0
    static let aspectRatioLabel = "16:10"
    static let maximumZoom: CGFloat = 4
    static let cropInset: CGFloat = 16
    static let cornerRadius: CGFloat = 12

    let containerSize: CGSize
    let imageSize: CGSize

    var cropSize: CGSize {
        let availableWidth = max(1, containerSize.width - Self.cropInset * 2)
        let availableHeight = max(1, containerSize.height - Self.cropInset * 2)

        var width = availableWidth
        var height = width / Self.aspectRatio

        if height > availableHeight {
            height = availableHeight
            width = height * Self.aspectRatio
        }

        return CGSize(width: max(1, width), height: max(1, height))
    }

    var cropRect: CGRect {
        CGRect(
            x: (containerSize.width - cropSize.width) / 2,
            y: (containerSize.height - cropSize.height) / 2,
            width: cropSize.width,
            height: cropSize.height
        )
    }

    func scale(zoom: CGFloat) -> CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else { return 0 }

        let baseScale = max(
            cropSize.width / imageSize.width,
            cropSize.height / imageSize.height
        )
        return baseScale * max(1, zoom)
    }

    func imageFrameSize(zoom: CGFloat) -> CGSize {
        let scale = scale(zoom: zoom)
        return CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
    }

    func clampedOffset(_ offset: CGSize, zoom: CGFloat) -> CGSize {
        let frame = imageFrameSize(zoom: zoom)
        let maximumX = max(0, (frame.width - cropSize.width) / 2)
        let maximumY = max(0, (frame.height - cropSize.height) / 2)

        return CGSize(
            width: min(max(offset.width, -maximumX), maximumX),
            height: min(max(offset.height, -maximumY), maximumY)
        )
    }

    /// The part of the image visible inside the crop window, expressed in the
    /// image's point coordinate space. The crop view renders this rect.
    func visibleImageRect(zoom: CGFloat, offset: CGSize) -> CGRect {
        let scale = scale(zoom: zoom)
        guard scale > 0 else { return .zero }

        let frame = imageFrameSize(zoom: zoom)
        let offset = clampedOffset(offset, zoom: zoom)
        let imageOrigin = CGPoint(
            x: cropRect.midX - frame.width / 2 + offset.width,
            y: cropRect.midY - frame.height / 2 + offset.height
        )

        let visibleRect = CGRect(
            x: (cropRect.minX - imageOrigin.x) / scale,
            y: (cropRect.minY - imageOrigin.y) / scale,
            width: cropRect.width / scale,
            height: cropRect.height / scale
        )
        .intersection(CGRect(origin: .zero, size: imageSize))

        return visibleRect.isNull ? .zero : visibleRect
    }
}
