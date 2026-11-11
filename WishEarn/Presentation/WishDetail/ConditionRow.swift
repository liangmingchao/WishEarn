import SwiftUI

struct ConditionRow: View {
    let condition: Condition
    var snapshot: ProgressSnapshot?
    var theme: WishTheme = .sage

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            icon

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Text(condition.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if !condition.isRequired {
                        Text("选填")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textTertiary)
                    }

                    if snapshot?.isCompleted == true,
                       condition.type != .checkpoint {
                        Image(systemName: "checkmark.circle.fill")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.success)
                            .accessibilityHidden(true)
                    }
                }

                Text(typeContext)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)

                if let direction = condition.amountDirection {
                    Text("金额方向：\(direction.displayName)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textTertiary)
                }

                if let snapshot {
                    if condition.type == .checkpoint {
                        checkpointState(snapshot)
                    } else {
                        progress(snapshot)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private var typeContext: String {
        switch condition.type {
        case .checkpoint:
            return condition.type.displayName
        default:
            return "\(condition.type.displayName) · \(condition.targetDescription)"
        }
    }

    private var icon: some View {
        Image(systemName: condition.type.symbolName)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(
                snapshot?.isCompleted == true
                    ? AppColors.success
                    : theme.onTint
            )
            .frame(width: 42, height: 42)
            .background(
                snapshot?.isCompleted == true
                    ? AppColors.successSoft
                    : theme.tint,
                in: RoundedRectangle(
                    cornerRadius: AppRadius.md,
                    style: .continuous
                )
            )
            .accessibilityHidden(true)
    }

    private func checkpointState(_ snapshot: ProgressSnapshot) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(
                systemName: snapshot.isCompleted
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .foregroundStyle(
                snapshot.isCompleted ? AppColors.success : AppColors.textTertiary
            )
            .accessibilityHidden(true)

            Text(snapshot.isCompleted ? "已完成" : "未完成")
                .font(AppTypography.footnote)
                .foregroundStyle(
                    snapshot.isCompleted ? AppColors.success : AppColors.textSecondary
                )
        }
    }

    private func progress(_ snapshot: ProgressSnapshot) -> some View {
        let current = NSDecimalNumber(decimal: snapshot.currentValue).stringValue
        let target = NSDecimalNumber(decimal: snapshot.targetValue).stringValue
        let unit = condition.unit.map { " \($0)" } ?? ""
        let text: String

        switch condition.type {
        case .streak:
            text = "连续 \(current) / \(target)\(unit)"
        default:
            text = "累计 \(current) / \(target)\(unit)"
        }

        return VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(text)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)

            ProgressIndicator(
                value: snapshot.progressRatio,
                accessibilityLabel: condition.title,
                accessibilityValue: text,
                style: .inline,
                isComplete: snapshot.isCompleted
            )
            .accessibilityHidden(true)
        }
    }
}
