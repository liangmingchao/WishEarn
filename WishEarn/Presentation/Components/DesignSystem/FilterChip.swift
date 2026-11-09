import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.callout.weight(.semibold))
                .foregroundStyle(
                    isSelected ? AppColors.accent : AppColors.textSecondary
                )
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, AppSpacing.md)
                .frame(minHeight: 36)
                .background(
                    isSelected ? AppColors.accentSoft : AppColors.surface,
                    in: Capsule()
                )
                .overlay {
                    if !isSelected {
                        Capsule()
                            .stroke(AppColors.separator, lineWidth: 1)
                    }
                }
                .frame(minHeight: AppLayout.touchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(Text(title))
    }
}

#Preview("Filter chips — Light") {
    FilterChipPreview()
        .preferredColorScheme(.light)
}

#Preview("Filter chips — Dark") {
    FilterChipPreview()
        .preferredColorScheme(.dark)
}

private struct FilterChipPreview: View {
    @State private var selected = "全部"

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(["全部", "进行中", "已解锁", "已兑现"], id: \.self) { title in
                FilterChip(
                    title: title,
                    isSelected: selected == title
                ) {
                    selected = title
                }
            }
        }
        .padding(AppSpacing.screenInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appScreenBackground()
    }
}
