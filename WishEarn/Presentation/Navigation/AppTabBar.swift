import SwiftUI

/// Flat editorial tab bar: canvas background, hairline rule, line icons.
///
/// iOS 26 renders the native tab bar as a floating glass capsule, which breaks
/// the paper look the redesign depends on. The app therefore hides the system
/// bar and draws this one, keeping the same four destinations and selection
/// binding (navigation stacks stay mounted inside `TabView`).
struct AppTabBar: View {
    @Binding var selection: AppRouter.Tab

    var body: some View {
        VStack(spacing: 0) {
            HairlineDivider()

            HStack(spacing: 0) {
                item(.wishes, title: "心愿", systemImage: "heart")
                item(.today, title: "行动", systemImage: "checkmark.circle")
                item(.achievements, title: "成就", systemImage: "trophy")
                item(.settings, title: "我的", systemImage: "person")
            }
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxs)
        }
        .background(AppColors.canvas)
    }

    private func item(
        _ tab: AppRouter.Tab,
        title: String,
        systemImage: String
    ) -> some View {
        let isSelected = selection == tab

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 7) {
                Capsule()
                    .fill(isSelected ? AppColors.textPrimary : Color.clear)
                    .frame(width: 14, height: 3)

                Image(systemName: systemImage)
                    .font(.system(size: 21, weight: isSelected ? .semibold : .regular))

                Text(title)
                    .font(.system(
                        size: 10.5,
                        weight: isSelected ? .semibold : .medium
                    ))
                    .tracking(0.2)
            }
            .foregroundStyle(
                isSelected ? AppColors.textPrimary : AppColors.textTertiary
            )
            .frame(maxWidth: .infinity)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel(Text(title))
    }
}

#Preview("Tab bar") {
    VStack {
        Spacer()
        AppTabBar(selection: .constant(.today))
    }
    .appScreenBackground()
}

extension View {
    /// Pins the editorial tab bar to a tab's root screen.
    ///
    /// Applied to the root (not to the TabView) so pushed screens cover it,
    /// matching the detail layout where the page action is the only bottom bar.
    func appTabBar(selection: Binding<AppRouter.Tab>) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            AppTabBar(selection: selection)
        }
    }
}
