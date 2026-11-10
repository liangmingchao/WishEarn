import Foundation
import UIKit

/// Renders a selected region of a photo into JPEG data.
///
/// The crop rect is in the UIImage's orientation-adjusted point space. Drawing
/// through UIGraphicsImageRenderer applies the image orientation correctly and
/// keeps this independent from the PhotosPicker data format.
enum ImageCropService {
    static let maximumPixelDimension: CGFloat = 2048

    static func crop(
        image: UIImage,
        to rect: CGRect,
        maximumPixelDimension: CGFloat = maximumPixelDimension
    ) -> Data? {
        guard image.size.width > 0,
              image.size.height > 0,
              maximumPixelDimension > 0 else {
            return nil
        }

        let imageBounds = CGRect(origin: .zero, size: image.size)
        let cropRect = rect.standardized.intersection(imageBounds)

        guard !cropRect.isNull,
              cropRect.width >= 1,
              cropRect.height >= 1 else {
            return nil
        }

        let sourcePixelSize = CGSize(
            width: cropRect.width * image.scale,
            height: cropRect.height * image.scale
        )
        let scaleDown = min(
            1,
            maximumPixelDimension / max(sourcePixelSize.width, sourcePixelSize.height)
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale * scaleDown
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: cropRect.size, format: format)
        let croppedImage = renderer.image { _ in
            image.draw(
                at: CGPoint(x: -cropRect.minX, y: -cropRect.minY)
            )
        }

        return croppedImage.jpegData(compressionQuality: 0.9)
    }
}
