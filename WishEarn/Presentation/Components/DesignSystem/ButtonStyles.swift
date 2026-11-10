import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.onPrimary)
            .frame(
                maxWidth: .infinity,
                minHeight: AppLayout.buttonHeight
            )
            .padding(.horizontal, AppSpacing.screenInset)
            .background(
                configuration.isPressed
                    ? AppColors.primaryPressed
                    : AppColors.primary
            )
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
            )
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.primary)
            .frame(
                maxWidth: .infinity,
                minHeight: AppLayout.buttonHeight
            )
            .padding(.horizontal, AppSpacing.screenInset)
            .background(
                AppColors.elevated.opacity(configuration.isPressed ? 0.72 : 1)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColors.separator, lineWidth: 1)
            )
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.callout)
            .foregroundStyle(
                AppColors.primary.opacity(configuration.isPressed ? 0.65 : 1)
            )
            .frame(minHeight: AppLayout.touchTarget)
            .padding(.horizontal, AppSpacing.sm)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var appPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var appSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == TertiaryButtonStyle {
    static var appTertiary: TertiaryButtonStyle { TertiaryButtonStyle() }
}

#Preview("Buttons — Light") {
    ButtonStylesPreview()
        .preferredColorScheme(.light)
}

#Preview("Buttons — Dark") {
    ButtonStylesPreview()
        .preferredColorScheme(.dark)
}

private struct ButtonStylesPreview: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Button("保存记录") {}
                .buttonStyle(.appPrimary)

            Button("稍后再说") {}
                .buttonStyle(.appSecondary)

            Button("查看全部") {}
                .buttonStyle(.appTertiary)
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
    }
}
