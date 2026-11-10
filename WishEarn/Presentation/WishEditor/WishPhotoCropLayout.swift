import CoreGraphics

enum WishPhotoCropHandle: String, CaseIterable, Identifiable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var id: String { rawValue }

    var accessibilityLabel: String {
        switch self {
        case .topLeft: return "左上角"
        case .topRight: return "右上角"
        case .bottomLeft: return "左下角"
        case .bottomRight: return "右下角"
        }
    }

    func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.minY)
        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }
}

/// Geometry for the freeform wish-photo cropper.
///
/// The image is aspect-fit so the complete photo is visible when the screen
/// opens. The crop rectangle starts at the full image bounds (normally the
/// phone-photo aspect ratio) and can be resized freely from any corner. Home
/// still presents the saved image in its own 2:1 frame, so the crop is a
/// composition aid rather than a promise that every surface shows identical
/// pixels.
struct WishPhotoCropLayout: Equatable {
    static let cropInset: CGFloat = 16
    static let minimumCropSide: CGFloat = 88
    static let maximumZoom: CGFloat = 4
    static let cornerRadius: CGFloat = 12

    let containerSize: CGSize
    let imageSize: CGSize
    let cropRect: CGRect

    init(
        containerSize: CGSize,
        imageSize: CGSize,
        cropRect: CGRect? = nil
    ) {
        self.containerSize = containerSize
        self.imageSize = imageSize

        let imageBounds = Self.aspectFitRect(
            imageSize: imageSize,
            in: containerSize
        )
        self.cropRect = cropRect.flatMap {
            Self.sanitizedCropRect($0, in: imageBounds)
        } ?? imageBounds
    }

    var imageRect: CGRect {
        Self.aspectFitRect(imageSize: imageSize, in: containerSize)
    }

    static func aspectFitRect(
        imageSize: CGSize,
        in containerSize: CGSize
    ) -> CGRect {
        guard imageSize.width > 0,
              imageSize.height > 0,
              containerSize.width > 0,
              containerSize.height > 0 else {
            return .zero
        }

        let availableWidth = max(1, containerSize.width - cropInset * 2)
        let availableHeight = max(1, containerSize.height - cropInset * 2)
        let scale = min(
            availableWidth / imageSize.width,
            availableHeight / imageSize.height
        )
        let size = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        return CGRect(
            x: (containerSize.width - size.width) / 2,
            y: (containerSize.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
    }

    static func sanitizedCropRect(
        _ rect: CGRect,
        in cropBounds: CGRect
    ) -> CGRect? {
        guard cropBounds.width > 0, cropBounds.height > 0 else {
            return nil
        }

        var rect = rect.standardized
        guard rect.origin.x.isFinite,
              rect.origin.y.isFinite,
              rect.width.isFinite,
              rect.height.isFinite else {
            return nil
        }

        rect = rect.intersection(cropBounds)

        guard !rect.isNull, rect.width >= 1, rect.height >= 1 else {
            return nil
        }

        let minimumWidth = min(minimumCropSide, cropBounds.width)
        let minimumHeight = min(minimumCropSide, cropBounds.height)
        guard rect.width < minimumWidth || rect.height < minimumHeight else {
            return rect
        }

        let width = max(rect.width, minimumWidth)
        let height = max(rect.height, minimumHeight)
        var expanded = CGRect(
            x: rect.midX - width / 2,
            y: rect.midY - height / 2,
            width: width,
            height: height
        )
        expanded.origin.x = min(
            max(expanded.origin.x, cropBounds.minX),
            max(cropBounds.minX, cropBounds.maxX - width)
        )
        expanded.origin.y = min(
            max(expanded.origin.y, cropBounds.minY),
            max(cropBounds.minY, cropBounds.maxY - height)
        )
        return expanded
    }

    static func resizedCropRect(
        from start: CGRect,
        handle: WishPhotoCropHandle,
        translation: CGSize,
        cropBounds: CGRect,
        minimumSide: CGFloat = minimumCropSide
    ) -> CGRect {
        let minimumWidth = min(minimumSide, cropBounds.width)
        let minimumHeight = min(minimumSide, cropBounds.height)
        var minX = start.minX
        var maxX = start.maxX
        var minY = start.minY
        var maxY = start.maxY

        switch handle {
        case .topLeft:
            minX = clamp(start.minX + translation.width, cropBounds.minX, start.maxX - minimumWidth)
            minY = clamp(start.minY + translation.height, cropBounds.minY, start.maxY - minimumHeight)
        case .topRight:
            maxX = clamp(start.maxX + translation.width, start.minX + minimumWidth, cropBounds.maxX)
            minY = clamp(start.minY + translation.height, cropBounds.minY, start.maxY - minimumHeight)
        case .bottomLeft:
            minX = clamp(start.minX + translation.width, cropBounds.minX, start.maxX - minimumWidth)
            maxY = clamp(start.maxY + translation.height, start.minY + minimumHeight, cropBounds.maxY)
        case .bottomRight:
            maxX = clamp(start.maxX + translation.width, start.minX + minimumWidth, cropBounds.maxX)
            maxY = clamp(start.maxY + translation.height, start.minY + minimumHeight, cropBounds.maxY)
        }

        return CGRect(
            x: minX,
            y: minY,
            width: max(1, maxX - minX),
            height: max(1, maxY - minY)
        )
    }

    func scale(zoom: CGFloat) -> CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else { return 0 }
        guard containerSize.width > 0, containerSize.height > 0 else { return 0 }

        let availableWidth = max(1, containerSize.width - Self.cropInset * 2)
        let availableHeight = max(1, containerSize.height - Self.cropInset * 2)
        let baseScale = min(
            availableWidth / imageSize.width,
            availableHeight / imageSize.height
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

        let minimumX = cropRect.maxX - containerSize.width / 2 - frame.width / 2
        let maximumX = cropRect.minX - containerSize.width / 2 + frame.width / 2
        let minimumY = cropRect.maxY - containerSize.height / 2 - frame.height / 2
        let maximumY = cropRect.minY - containerSize.height / 2 + frame.height / 2

        return CGSize(
            width: Self.clamp(offset.width, minimumX, maximumX),
            height: Self.clamp(offset.height, minimumY, maximumY)
        )
    }

    /// The part of the image visible inside the crop rectangle, expressed in
    /// the image's point coordinate space. The crop view renders this rect.
    func visibleImageRect(zoom: CGFloat, offset: CGSize) -> CGRect {
        let scale = scale(zoom: zoom)
        guard scale > 0 else { return .zero }

        let frame = imageFrameSize(zoom: zoom)
        let offset = clampedOffset(offset, zoom: zoom)
        let imageOrigin = CGPoint(
            x: containerSize.width / 2 - frame.width / 2 + offset.width,
            y: containerSize.height / 2 - frame.height / 2 + offset.height
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

    private static func clamp(
        _ value: CGFloat,
        _ lower: CGFloat,
        _ upper: CGFloat
    ) -> CGFloat {
        guard lower <= upper else { return lower }
        return min(max(value, lower), upper)
    }
}
