import SwiftUI

struct CardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func appCard(padding: CGFloat = AppSpacing.lg) -> some View {
        modifier(CardModifier(padding: padding))
    }
}
