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
        HStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(foregroundColor)
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(foregroundColor)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }

    private var foregroundColor: Color {
        switch tone {
        case .neutral: return AppColors.textSecondary
        case .primary: return AppColors.accent
        case .success: return AppColors.success
        case .warning: return AppColors.warning
        case .danger: return AppColors.danger
        }
    }
}

#Preview("Status — Light") {
    StatusBadgePreview()
        .preferredColorScheme(.light)
}

#Preview("Status — Dark") {
    StatusBadgePreview()
        .preferredColorScheme(.dark)
}

private struct StatusBadgePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            StatusBadge(title: "进行中", tone: .primary)
            StatusBadge(title: "已解锁", tone: .success)
            StatusBadge(title: "已暂停", tone: .warning)
            StatusBadge(title: "需要处理", tone: .danger)
            StatusBadge(title: "已兑现", tone: .neutral)
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .appScreenBackground()
    }
}
