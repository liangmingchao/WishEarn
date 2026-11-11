import SwiftUI
import UIKit

/// A ceremonial "reward unlocked" page. The first phase celebrates the wish
/// unlock; after claiming, the page stays on screen to confirm the reward and
/// only then dismisses. This keeps the most important moment from ending the
/// instant the user taps the primary button.
struct UnlockCelebrationView: View {
    let wish: Wish
    let imageData: Data?
    let requiredConditionCount: Int
    let onClaim: () -> Bool
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var appeared = false
    @State private var isClaimed = false

    private var theme: WishTheme {
        .forWish(wish)
    }

    private var claimedDateText: String {
        Date.now.formatted(
            .dateTime.year().month().day()
                .locale(Locale(identifier: "zh_CN"))
        )
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            background

            GeometryReader { proxy in
                ScrollView {
                    Group {
                        if isClaimed {
                            claimedContent
                        } else {
                            unlockedContent
                        }
                    }
                    .frame(minHeight: proxy.size.height)
                }
                .scrollIndicators(.hidden)
            }

            closeButton
        }
        .safeAreaInset(edge: .bottom) {
            actionBar
        }
        .onAppear {
            withAnimation(
                reduceMotion
                    ? .easeOut(duration: 0.2)
                    : .spring(response: 0.62, dampingFraction: 0.8)
            ) {
                appeared = true
            }
        }
        .onChange(of: isClaimed) { _, claimed in
            guard claimed, UIAccessibility.isVoiceOverRunning else { return }
            UIAccessibility.post(
                notification: .announcement,
                argument: "奖励已领取"
            )
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: appeared)
        .sensoryFeedback(.success, trigger: isClaimed)
    }

    // MARK: - Unlocked phase

    private var unlockedContent: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer(minLength: AppSpacing.lg)

            celebrationKicker(
                "心愿达成",
                textColor: AppColors.textSecondary,
                sparkleColor: AppColors.clay
            )
            .opacity(appeared ? 1 : 0)

            hero(stamp: "已达成", stampColor: AppColors.clayText)

            VStack(spacing: AppSpacing.sm) {
                Text("你做到了")
                    .font(AppTypography.display)
                    .tracking(-1.2)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("「\(wish.title)」已解锁")
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(appeared ? 1 : 0)

            proofRow

            Text("这份奖励，是你一步步换来的。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)

            Spacer(minLength: AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppLayout.touchTarget + AppSpacing.sm)
        .padding(.bottom, AppSpacing.xl)
    }

    private func celebrationKicker(
        _ text: String,
        textColor: Color,
        sparkleColor: Color
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(sparkleColor)
                .accessibilityHidden(true)

            Text(text)
                .font(AppTypography.kicker)
                .tracking(2.2)
                .foregroundStyle(textColor)

            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(sparkleColor)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(text))
    }

    private var proofRow: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primary)
                .accessibilityHidden(true)

            Text(proofText)
                .font(AppTypography.callout.weight(.medium))
                .foregroundStyle(AppColors.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, AppSpacing.md + 2)
        .padding(.vertical, AppSpacing.sm + 2)
        .background(AppColors.primarySoft, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(proofText))
    }

    private var proofText: String {
        requiredConditionCount > 0
            ? "\(requiredConditionCount) 项必需条件，全部完成"
            : "解锁条件已完成"
    }

    private var actionBar: some View {
        VStack(spacing: AppSpacing.sm) {
            if isClaimed {
                Button("完成", action: onDismiss)
                    .buttonStyle(.appPrimary)
                    .accessibilityIdentifier("unlockFinishButton")
            } else {
                Button("领取这份奖励", action: claim)
                    .buttonStyle(.appPrimary)
                    .accessibilityIdentifier("unlockClaimButton")
                    .accessibilityHint("将心愿标记为已兑现")

                Button("稍后再说", action: onDismiss)
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(minHeight: AppLayout.touchTarget)
                    .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.sm)
        .frame(maxWidth: .infinity)
        .background {
            AppColors.canvas.opacity(0.97)
                .overlay(alignment: .top) {
                    UnlockRule()
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func claim() {
        guard !isClaimed, onClaim() else { return }

        withAnimation(
            reduceMotion
                ? .easeOut(duration: 0.25)
                : .spring(response: 0.5, dampingFraction: 0.72)
        ) {
            isClaimed = true
        }
    }

    // MARK: - Claimed phase

    private var claimedContent: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer(minLength: AppSpacing.lg)

            celebrationKicker(
                "奖励已领取",
                textColor: AppColors.primary,
                sparkleColor: AppColors.primary
            )

            hero(stamp: "已领取", stampColor: AppColors.primary)

            VStack(spacing: AppSpacing.sm) {
                Text("这份奖励，属于你了")
                    .font(AppTypography.display)
                    .tracking(-1.2)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("「\(wish.title)」")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            receipt

            Text("它会留在成就页，提醒你曾经认真对待过这个心愿。")
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.screenInset)
        .padding(.top, AppLayout.touchTarget + AppSpacing.sm)
        .padding(.bottom, AppSpacing.xl)
    }

    private var receipt: some View {
        VStack(spacing: 0) {
            receiptRow(title: "领取日期", value: claimedDateText)
            UnlockRule()
            receiptRow(
                title: "完成条件",
                value: requiredConditionCount > 0
                    ? "\(requiredConditionCount) 项"
                    : "已完成"
            )
        }
        .padding(.horizontal, AppSpacing.lg)
        .background(
            AppColors.elevated,
            in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(AppColors.separator, lineWidth: 1)
        }
        .frame(maxWidth: 360)
    }

    private func receiptRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)

            Spacer(minLength: AppSpacing.sm)

            Text(value)
                .font(AppTypography.callout.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, AppSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title)，\(value)"))
    }

    // MARK: - Shared pieces

    private var background: some View {
        ZStack {
            AppColors.canvas

            RadialGradient(
                colors: [
                    theme.tint.opacity(colorScheme == .dark ? 0.16 : 0.30),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.10),
                startRadius: 16,
                endRadius: 520
            )

            LinearGradient(
                colors: [
                    .clear,
                    AppColors.primarySoft.opacity(isClaimed ? 0.55 : 0)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private func hero(stamp: String, stampColor: Color) -> some View {
        ZStack {
            if !reduceMotion {
                CelebrationBurst(theme: theme)
                    .frame(width: 340, height: 340)
            }

            photoCard
                .overlay(alignment: .bottomTrailing) {
                    AchievementStamp(title: stamp, color: stampColor)
                        .offset(x: 10, y: 12)
                }
        }
        .frame(maxWidth: 360)
        .scaleEffect(appeared ? 1 : 0.96)
        .opacity(appeared ? 1 : 0)
    }

    private var photoCard: some View {
        ZStack {
            theme.softTint

            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .accessibilityLabel("\(wish.title) 的照片")
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 48, weight: .light))
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
        .padding(10)
        .background(
            AppColors.surface,
            in: RoundedRectangle(
                cornerRadius: AppRadius.xxl,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: AppRadius.xxl,
                style: .continuous
            )
            .stroke(AppColors.separator, lineWidth: 1)
        }
    }

    private var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(
                    width: AppLayout.touchTarget,
                    height: AppLayout.touchTarget
                )
                .background(AppColors.surface.opacity(0.92), in: Circle())
                .overlay {
                    Circle()
                        .stroke(AppColors.separator, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("关闭")
        .padding(.top, AppSpacing.sm)
        .padding(.trailing, AppSpacing.screenInset)
    }
}

/// A one-shot confetti burst drawn from the wish's muted theme colors.
private struct CelebrationBurst: View {
    let theme: WishTheme

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0

    private let particleCount = 20

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                particle(index)
                    .offset(
                        x: cos(angle(index)) * distance(index) * progress,
                        y: sin(angle(index)) * distance(index) * progress
                    )
                    .rotationEffect(
                        .degrees(
                            progress * (index.isMultiple(of: 2) ? 160 : -160)
                        )
                    )
                    .scaleEffect(0.4 + progress * 0.6)
                    .opacity(progress == 0 ? 0 : (1 - progress) * 0.9)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            if reduceMotion {
                progress = 1
            } else {
                withAnimation(.easeOut(duration: 1.2)) {
                    progress = 1
                }
            }
        }
    }

    @ViewBuilder
    private func particle(_ index: Int) -> some View {
        if index.isMultiple(of: 4) {
            Image(systemName: "sparkle")
                .font(
                    .system(
                        size: 14 + CGFloat(index % 3) * 3,
                        weight: .semibold
                    )
                )
                .foregroundStyle(color(index))
        } else {
            Circle()
                .fill(color(index))
                .frame(
                    width: 5 + CGFloat(index % 3) * 2,
                    height: 5 + CGFloat(index % 3) * 2
                )
        }
    }

    private func angle(_ index: Int) -> CGFloat {
        CGFloat(index) / CGFloat(particleCount) * 2 * .pi
    }

    private func distance(_ index: Int) -> CGFloat {
        180 + CGFloat(index % 5) * 9
    }

    private func color(_ index: Int) -> Color {
        [
            AppColors.clay,
            AppColors.primary,
            AppColors.textPrimary,
            theme.tint
        ][index % 4]
    }
}

private struct AchievementStamp: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(.headline, design: .rounded).weight(.heavy))
            .tracking(2.4)
            .foregroundStyle(color)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                AppColors.surface.opacity(0.94),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(color, lineWidth: 2)
            }
            .rotationEffect(.degrees(-8))
            .accessibilityHidden(true)
    }
}

private struct UnlockRule: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.separator)
            .frame(height: 0.5)
            .accessibilityHidden(true)
    }
}

#Preview("Unlocked — Light") {
    if let wish = try? Wish(
        title: "Kindle Paperwhite",
        createdAt: .now,
        updatedAt: .now
    ) {
        UnlockCelebrationView(
            wish: wish,
            imageData: nil,
            requiredConditionCount: 3,
            onClaim: { true },
            onDismiss: {}
        )
        .preferredColorScheme(.light)
    }
}

#Preview("Unlocked — Dark") {
    if let wish = try? Wish(
        title: "Kindle Paperwhite",
        createdAt: .now,
        updatedAt: .now
    ) {
        UnlockCelebrationView(
            wish: wish,
            imageData: nil,
            requiredConditionCount: 3,
            onClaim: { true },
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
            onClaim: { true },
            onDismiss: {}
        )
        .environment(\.dynamicTypeSize, .accessibility3)
    }
}
