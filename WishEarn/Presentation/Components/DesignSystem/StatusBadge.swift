import SwiftUI

struct StatusBadge: View {
    enum Tone {
        case neutral
        case primary
        case success
        case warning
        case danger
    }

    let title: String
    var tone: Tone = .neutral

    var body: some View {
        Text(title)
            .font(AppTypography.caption)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var foregroundColor: Color {
        switch tone {
        case .neutral: AppColors.textSecondary
        case .primary: AppColors.primary
        case .success: AppColors.success
        case .warning: AppColors.warning
        case .danger: AppColors.danger
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.14)
    }
}
