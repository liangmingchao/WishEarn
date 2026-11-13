import SwiftUI
import UIKit

/// The moment a wish unlocks. Deliberately the only screen in the app that
/// leaves the paper palette: ink-dark ground, amber seal, one white action.
struct UnlockCelebrationView: View {
    let wish: Wish
    let imageData: Data?
    let requiredConditionCount: Int
    let onClaim: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var theme: WishTheme {
        .forWish(wish)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColors.ceremony
                .ignoresSafeArea()

            ambientLight

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: AppSpacing.lg)

                        seal
                            .scaleEffect(reduceMotion ? 1 : (appeared ? 1 : 0.88))
                            .opacity(appeared ? 1 : 0)

                        Text("你做到了")
                            .font(.system(size: 34, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.onImage)
                            .padding(.top, AppSpacing.xl)

                        Text("「\(wish.title)」已解锁")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(AppColors.onImage.opacity(0.72))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, AppSpacing.sm)
                            .padding(.horizontal, AppSpacing.lg)

                        facts
                            .padding(.top, AppSpacing.xl)

                        if let priceText {
                            Text(priceText)
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundStyle(AppColors.onImage.opacity(0.55))
                                .padding(.top, AppSpacing.md)
                        }

                        Spacer(minLength: AppSpacing.xl)

                        closingLine

                        actions
                            .padding(.top, AppSpacing.lg)
                    }
                    .frame(minHeight: proxy.size.height)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, AppLayout.touchTarget + AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
                    .opacity(appeared ? 1 : 0)
                }
                .scrollIndicators(.hidden)
            }

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.onImage.opacity(0.7))
                    .frame(width: 34, height: 34)
                    .background(AppColors.onImage.opacity(0.10), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("关闭")
            .padding(.top, AppSpacing.sm)
            .padding(.trailing, AppSpacing.screenInset)
        }
        .onAppear {
            if reduceMotion {
                withAnimation(.easeOut(duration: 0.2)) {
                    appeared = true
                }
            } else {
                withAnimation(AppMotion.ceremony) {
                    appeared = true
                }
            }
        }
    }

    private var ambientLight: some View {
        RadialGradient(
            colors: [
                AppColors.coral.opacity(0.18),
                AppColors.ceremony.opacity(0)
            ],
            center: .init(x: 0.5, y: 0.18),
            startRadius: 8,
            endRadius: 340
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var seal: some View {
        ZStack {
            Circle()
                .stroke(AppColors.coral.opacity(0.45), lineWidth: 1)
                .frame(width: 104, height: 104)

            Circle()
                .stroke(AppColors.coral.opacity(0.22), lineWidth: 1)
                .frame(width: 122, height: 122)

            Circle()
                .fill(AppColors.coral.opacity(0.12))
                .frame(width: 84, height: 84)

            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(AppColors.coral)
        }
        .accessibilityHidden(true)
    }

    private var facts: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.onImage.opacity(0.12))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                fact(
                    value: "\(requiredConditionCount)",
                    label: "项条件"
                )

                divider

                fact(
                    value: "100%",
                    label: "完成度"
                )

                divider

                fact(
                    value: "今日",
                    label: "解锁"
                )
            }
            .padding(.vertical, AppSpacing.lg)

            Rectangle()
                .fill(AppColors.onImage.opacity(0.12))
                .frame(height: 0.5)
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private func fact(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppColors.onImage)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.onImage.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.onImage.opacity(0.12))
            .frame(width: 0.5, height: 26)
    }

    private var closingLine: some View {
        Text("这份奖励，是你自己换来的。")
            .font(.system(size: 13, weight: .regular, design: .serif))
            .foregroundStyle(AppColors.onImage.opacity(0.55))
            .multilineTextAlignment(.center)
    }

    private var actions: some View {
        VStack(spacing: AppSpacing.sm) {
            Button(action: onClaim) {
                Text("领取我的奖励")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.ceremony)
                    .frame(maxWidth: .infinity, minHeight: AppLayout.buttonHeight)
                    .background(
                        AppColors.onImage,
                        in: RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("unlockClaimButton")

            Button("稍后再说", action: onDismiss)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.onImage.opacity(0.55))
                .frame(minHeight: AppLayout.touchTarget)
                .buttonStyle(.plain)
        }
        .frame(maxWidth: 360)
    }

    private var priceText: String? {
        guard let price = wish.targetPrice else { return nil }
        return price.formatted(
            .currency(code: wish.currencyCode)
            .locale(Locale(identifier: "zh_CN"))
        )
    }
}

#Preview("Light") {
    if let wish = try? Wish(
        title: "Kindle Paperwhite",
        createdAt: .now,
        updatedAt: .now
    ) {
        UnlockCelebrationView(
            wish: wish,
            imageData: nil,
            requiredConditionCount: 3,
            onClaim: {},
            onDismiss: {}
        )
        .preferredColorScheme(.light)
    }
}

#Preview("Dark") {
    if let wish = try? Wish(
        title: "Kindle Paperwhite",
        createdAt: .now,
        updatedAt: .now
    ) {
        UnlockCelebrationView(
            wish: wish,
            imageData: nil,
            requiredConditionCount: 3,
            onClaim: {},
            onDismiss: {}
        )
        .preferredColorScheme(.dark)
    }
}

#Preview("Accessibility Text") {
    if let wish = try? Wish(
        title: "一台可以陪伴很多年、每天阅读都觉得很安静的 Kindle Paperwhite",
        createdAt: .now,
        updatedAt: .now
    ) {
        UnlockCelebrationView(
            wish: wish,
            imageData: nil,
            requiredConditionCount: 3,
            onClaim: {},
            onDismiss: {}
        )
        .environment(\.dynamicTypeSize, .accessibility3)
    }
}
