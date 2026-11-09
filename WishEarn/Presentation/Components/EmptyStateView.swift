import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .light))
                .foregroundStyle(AppColors.accent)
                .frame(
                    width: AppLayout.touchTarget,
                    height: AppLayout.touchTarget
                )
                .accessibilityHidden(true)

            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)

            Text(message)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.appPrimary)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview("Empty — Light") {
    EmptyStatePreview()
        .preferredColorScheme(.light)
}

#Preview("Empty — Dark") {
    EmptyStatePreview()
        .preferredColorScheme(.dark)
}

#Preview("Empty — Accessibility Text") {
    EmptyStatePreview()
        .environment(\.dynamicTypeSize, .accessibility3)
}

private struct EmptyStatePreview: View {
    var body: some View {
        EmptyStateView(
            systemImage: "heart.text.square",
            title: "给自己一个值得期待的目标",
            message: "选一件真正想要的东西，再决定要为它付出哪些努力。",
            actionTitle: "创建第一个心愿",
            action: {}
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
    }
}
