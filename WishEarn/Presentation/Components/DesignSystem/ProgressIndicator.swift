import SwiftUI

struct ProgressIndicator: View {
    enum Style {
        case inline
        case hero

        var height: CGFloat {
            switch self {
            case .inline: return 4
            case .hero: return 6
            }
        }
    }

    let value: Double
    let accessibilityLabel: String
    let accessibilityValue: String
    var style: Style = .inline
    var isComplete = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.progressTrack)

                Capsule()
                    .fill(isComplete ? AppColors.success : AppColors.accent)
                    .frame(width: proxy.size.width * clampedValue)
            }
        }
        .frame(height: style.height)
        .animation(
            reduceMotion ? nil : AppMotion.standard,
            value: clampedValue
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityLabel))
        .accessibilityValue(Text(accessibilityValue))
    }

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }
}

#Preview("Progress — Light") {
    ProgressIndicatorPreview()
        .preferredColorScheme(.light)
}

#Preview("Progress — Dark") {
    ProgressIndicatorPreview()
        .preferredColorScheme(.dark)
}

#Preview("Progress — Accessibility Text") {
    ProgressIndicatorPreview()
        .environment(\.dynamicTypeSize, .accessibility3)
}

private struct ProgressIndicatorPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            progressRow(
                title: "尚未开始",
                value: 0,
                valueText: "已完成 0 项，共 3 项"
            )
            progressRow(
                title: "推进中",
                value: 0.4,
                valueText: "已完成 1 项，共 3 项"
            )
            progressRow(
                title: "已完成",
                value: 1,
                valueText: "已完成 3 项，共 3 项",
                isComplete: true,
                style: .hero
            )
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }

    private func progressRow(
        title: String,
        value: Double,
        valueText: String,
        isComplete: Bool = false,
        style: ProgressIndicator.Style = .inline
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.callout)
                .foregroundStyle(AppColors.textPrimary)
            ProgressIndicator(
                value: value,
                accessibilityLabel: title,
                accessibilityValue: valueText,
                style: style,
                isComplete: isComplete
            )
        }
    }
}
