import SwiftUI

struct EditorField<Content: View>: View {
    let title: String
    var helperText: String?
    var errorText: String?
    private let content: Content

    init(
        title: String,
        helperText: String? = nil,
        errorText: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.helperText = helperText
        self.errorText = errorText
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.kicker)
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)

            content
                .font(AppTypography.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, AppSpacing.md)
                .overlay(alignment: .bottom) {
                    HairlineDivider()
                }

            if let errorText {
                Text(errorText)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.danger)
                    .fixedSize(horizontal: false, vertical: true)
            } else if let helperText {
                Text(helperText)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview("Field — Light") {
    EditorFieldPreview()
        .preferredColorScheme(.light)
}

#Preview("Field — Dark") {
    EditorFieldPreview()
        .preferredColorScheme(.dark)
}

#Preview("Field — Error") {
    EditorFieldPreview()
        .preferredColorScheme(.light)
        .environment(\.dynamicTypeSize, .accessibility2)
}

private struct EditorFieldPreview: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            EditorField(
                title: "心愿名称",
                helperText: "必填"
            ) {
                Text("Kindle Paperwhite")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            EditorField(
                title: "目标值",
                errorText: "连续坚持的目标值必须为正整数。"
            ) {
                Text("1.5")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
