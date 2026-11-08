import SwiftUI

struct RootTabView: View {
    @Bindable var router: AppRouter
    let container: AppContainer

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                WishListView()
            }
            .tabItem {
                Label("心愿", systemImage: "heart")
            }
            .tag(AppRouter.Tab.wishes)

            NavigationStack {
                TodayView(viewModel: container.makeTodayViewModel())
            }
            .tabItem {
                Label("行动", systemImage: "checkmark.circle")
            }
            .tag(AppRouter.Tab.today)

            NavigationStack {
                AchievementsView()
            }
            .tabItem {
                Label("成就", systemImage: "trophy")
            }
            .tag(AppRouter.Tab.achievements)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
            .tag(AppRouter.Tab.settings)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    let container = AppContainer.preview()
    RootTabView(router: container.router, container: container)
}
