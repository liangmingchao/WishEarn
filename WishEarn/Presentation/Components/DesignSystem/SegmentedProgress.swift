import SwiftUI

/// Discrete condition progress: one segment per required condition.
///
/// Editorial Paper replaces the continuous bar in hero positions because
/// conditions are countable; the segments make “how many steps are left”
/// readable at a glance. Callers fall back to `ProgressIndicator` when the
/// condition count is too large to segment legibly.
struct SegmentedProgress: View {
    let completed: Int
    let total: Int
    var height: CGFloat = 6

    private var segmentCount: Int {
        max(total, 1)
    }

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<segmentCount, id: \.self) { index in
                Capsule()
                    .fill(
                        index < completed
                            ? AppColors.primary
                            : AppColors.progressTrack
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("条件进度"))
        .accessibilityValue(
            Text("已完成 \(completed) 项，共 \(total) 项条件")
        )
    }
}

/// 1pt rule used to separate editorial rows.
struct HairlineDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.separator)
            .frame(height: 0.5)
            .accessibilityHidden(true)
    }
}

#Preview("Segmented progress") {
    VStack(alignment: .leading, spacing: AppSpacing.xl) {
        SegmentedProgress(completed: 0, total: 3)
        SegmentedProgress(completed: 2, total: 5)
        SegmentedProgress(completed: 4, total: 4)
        HairlineDivider()
    }
    .padding(AppSpacing.screenInset)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .appScreenBackground()
}
