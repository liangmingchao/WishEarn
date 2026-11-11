import SwiftUI
import UIKit

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
            LinearGradient(
                colors: [
                    theme.tint.opacity(0.34),
                    AppColors.canvas,
                    AppColors.claySoft
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        Spacer(minLength: AppSpacing.lg)

                        imageView
                            .scaleEffect(reduceMotion ? 1 : (appeared ? 1 : 0.94))
                            .opacity(appeared ? 1 : 0)

                        WishThemeMark(theme: theme, width: 42)

                        Text("你做到了")
                            .font(AppTypography.display)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("「\(wish.title)」已解锁")
                            .font(AppTypography.title)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        supportingText
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: AppSpacing.xl)

                        actions
                        Spacer(minLength: AppSpacing.lg)
                    }
                    .frame(minHeight: proxy.size.height)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, AppLayout.touchTarget + AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
                }
                .scrollIndicators(.hidden)
            }

            Button("关闭", action: onDismiss)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .frame(minHeight: AppLayout.touchTarget)
                .background(AppColors.surface.opacity(0.9), in: Capsule())
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
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    appeared = true
                }
            }
        }
    }

    private var supportingText: Text {
        if requiredConditionCount > 0 {
            return Text("你完成了为它设定的 \(requiredConditionCount) 项条件")
        }
        return Text("解锁条件已完成")
    }

    private var actions: some View {
        VStack(spacing: AppSpacing.sm) {
            Button("领取这份奖励", action: onClaim)
                .buttonStyle(.appPrimary)
                .accessibilityIdentifier("unlockClaimButton")

            Button("稍后再说", action: onDismiss)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .frame(minHeight: AppLayout.touchTarget)
                .buttonStyle(.plain)
        }
        .frame(maxWidth: 360)
    }

    private var imageView: some View {
        ZStack {
            theme.softTint

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .accessibilityLabel("\(wish.title) 的照片")
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(theme.onSoftTint)
                    .accessibilityHidden(true)
            }
        }
        .aspectRatio(4.0 / 3.0, contentMode: .fit)
        .frame(maxWidth: 320)
        .clipped()
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
        .shadow(
            color: AppColors.accent.opacity(0.18),
            radius: 24,
            x: 0,
            y: 12
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
