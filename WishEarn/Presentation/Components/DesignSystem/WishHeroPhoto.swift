import SwiftUI
import UIKit

/// Hero imagery for a wish: the user's own photo, cropped to 4:3.
///
/// Editorial Paper does not draw bespoke illustrations; the wish photo is the
/// visual anchor. When a wish has no photo the theme wash plus a quiet photo
/// glyph keeps the composition without inventing content.
struct WishHeroPhoto: View {
    let imageData: Data?
    let theme: WishTheme
    var cornerRadius: CGFloat = AppRadius.xl

    var body: some View {
        Color.clear
            .aspectRatio(AppLayout.heroAspectRatio, contentMode: .fit)
            .overlay {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        theme.softTint

                        Image(systemName: "photo")
                            .font(.system(size: 34, weight: .light))
                            .foregroundStyle(theme.onSoftTint.opacity(0.55))
                    }
                }
            }
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

#Preview("Hero photo") {
    VStack(spacing: AppSpacing.lg) {
        WishHeroPhoto(imageData: nil, theme: .mint)
    }
    .padding(AppSpacing.screenInset)
    .appScreenBackground()
}
