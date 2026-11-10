import SwiftUI

/// One condition as an editorial list row: title plus a single metadata line.
/// The leading completion mark is owned by the detail screen, so this row does
/// not repeat the state icon or a second progress bar.
struct ConditionRow: View {
    let condition: Condition
    var snapshot: ProgressSnapshot?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: AppSpacing.sm) {
                Text(condition.title)
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if !condition.isRequired {
                    Text("选填")
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Text(detailText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textTertiary)
                .lineLimit(1)
        }
        .padding(.vertical, AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var detailText: String {
        guard let snapshot else {
            return condition.type.displayName
        }

        let current = NSDecimalNumber(decimal: snapshot.currentValue).stringValue
        let target = NSDecimalNumber(decimal: snapshot.targetValue).stringValue
        let unit = condition.unit.map { " \($0)" } ?? ""

        switch condition.type {
        case .checkpoint:
            return snapshot.isCompleted ? "已完成" : "目标完成"
        case .streak:
            return "连续 \(current) / \(target)\(unit)"
        default:
            return "累计 \(current) / \(target)\(unit)"
        }
    }
}
