import SwiftUI

struct WishListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                EmptyStateView(
                    systemImage: "heart.text.square",
                    title: "还没有心愿",
                    message: "给自己设定一个值得努力的目标吧。"
                )
                .padding(.top, AppSpacing.xxl)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.lg)
        }
        .appScreenBackground()
        .navigationTitle("心愿")
    }
}

#Preview {
    NavigationStack {
        WishListView()
    }
}
