import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.onPrimary)
            .frame(
                maxWidth: .infinity,
                minHeight: AppLayout.primaryButtonHeight
            )
            .padding(.horizontal, AppSpacing.screenInset)
            .background {
                if configuration.isPressed {
                    Capsule()
                        .fill(AppColors.primaryPressed)
                } else {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.primaryGradientStart,
                                    AppColors.primaryGradientEnd
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .shadow(
                color: AppColors.primary.opacity(
                    configuration.isPressed ? 0.10 : 0.22
                ),
                radius: configuration.isPressed ? 4 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 6
            )
            .scaleEffect(
                configuration.isPressed && !reduceMotion ? 0.99 : 1
            )
            .animation(AppMotion.quick, value: configuration.isPressed)
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
                AppColors.surface.opacity(configuration.isPressed ? 0.72 : 1),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(AppColors.primary, lineWidth: 1.2)
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
