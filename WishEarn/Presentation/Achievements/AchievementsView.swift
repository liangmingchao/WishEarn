import SwiftUI

struct AchievementsView: View {
    var body: some View {
        ScrollView {
            EmptyStateView(
                systemImage: "trophy",
                title: "还没有成就",
                message: "完成第一个心愿后，成就会出现在这里。"
            )
            .padding(AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)
        }
        .appScreenBackground()
        .navigationTitle("成就")
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
}
