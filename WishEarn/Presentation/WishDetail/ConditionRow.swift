import SwiftUI

struct ConditionRow: View {
    let condition: Condition
    var snapshot: ProgressSnapshot? = nil

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: condition.type.symbolName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColors.primary)
                .frame(width: 36, height: 36)
                .background(AppColors.primarySoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.sm) {
                    Text(condition.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    if condition.isRequired {
                        StatusBadge(title: "必需", tone: .primary)
                    }
                }

                Text("\(condition.type.displayName) · \(condition.targetDescription)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)

                if let direction = condition.amountDirection {
                    Text("金额方向：\(direction.displayName)")
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if let snapshot {
                    HStack {
                        Text("\(NSDecimalNumber(decimal: snapshot.currentValue).stringValue) / \(NSDecimalNumber(decimal: snapshot.targetValue).stringValue)")
                        Spacer()
                        Text("\(Int(snapshot.progressRatio * 100))%")
                    }
                    .font(AppTypography.caption2)
                    .foregroundStyle(AppColors.textSecondary)

                    ProgressView(value: snapshot.progressRatio)
                        .tint(snapshot.isCompleted ? AppColors.success : AppColors.primary)
                }
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
