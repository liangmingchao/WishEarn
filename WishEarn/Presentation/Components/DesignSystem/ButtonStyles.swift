import SwiftUI

/// The single filled capsule action of a screen.
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
            .clipShape(Capsule())
    }
}

/// Quiet secondary action: hairline capsule on the canvas.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.textPrimary)
            .frame(
                maxWidth: .infinity,
                minHeight: AppLayout.buttonHeight
            )
            .padding(.horizontal, AppSpacing.screenInset)
            .background(AppColors.canvas.opacity(configuration.isPressed ? 0.6 : 1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColors.separator, lineWidth: 1)
            )
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.callout)
            .foregroundStyle(
                AppColors.primary.opacity(configuration.isPressed ? 0.55 : 1)
            )
            .frame(minHeight: AppLayout.touchTarget)
            .padding(.horizontal, AppSpacing.sm)
            .contentShape(Rectangle())
    }
}

/// Row-level action: compact outlined capsule that keeps a 44pt hit area.
struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.caption.weight(.semibold))
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                AppColors.canvas.opacity(configuration.isPressed ? 0.55 : 1)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColors.separator, lineWidth: 1)
            )
            .frame(minHeight: AppLayout.touchTarget)
            .contentShape(Capsule())
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

extension ButtonStyle where Self == PillButtonStyle {
    static var appPill: PillButtonStyle { PillButtonStyle() }
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
            Button("记录这次的阅读") {}
                .buttonStyle(.appPrimary)

            Button("稍后再说") {}
                .buttonStyle(.appSecondary)

            Button("记录") {}
                .buttonStyle(.appPill)

            Button("查看全部") {}
                .buttonStyle(.appTertiary)
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
    }
}
