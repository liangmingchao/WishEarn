import SwiftUI

struct RootTabView: View {
    @Bindable var router: AppRouter
    @Bindable var unlockCoordinator: UnlockCoordinator
    let container: AppContainer

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                WishListView(
                    viewModel: container.makeWishListViewModel(),
                    makeEditorViewModel: container.makeWishEditorViewModel(wish:),
                    makeDetailViewModel: container.makeWishDetailViewModel(wish:),
                    makeConditionEditorViewModel: container.makeConditionEditorViewModel(wishID:condition:sortOrder:),
                    makeConditionDetailViewModel: container.makeConditionDetailViewModel(condition:),
                    makeRecordEditorViewModel: container.makeRecordEditorViewModel(condition:record:)
                )
            }
            .tabItem {
                Label("心愿", systemImage: "heart")
            }
            .tag(AppRouter.Tab.wishes)

            NavigationStack {
                TodayView(
                    viewModel: container.makeTodayViewModel(),
                    makeRecordEditorViewModel: { condition in
                        container.makeRecordEditorViewModel(condition: condition, record: nil)
                    },
                    makeWishEditorViewModel: {
                        container.makeWishEditorViewModel()
                    }
                )
            }
            .tabItem {
                Label("行动", systemImage: "checkmark.circle")
            }
            .tag(AppRouter.Tab.today)

            NavigationStack {
                AchievementsView(viewModel: container.makeAchievementsViewModel())
            }
            .tabItem {
                Label("成就", systemImage: "trophy")
            }
            .tag(AppRouter.Tab.achievements)

            NavigationStack {
                SettingsView(dataExportService: container.dataExportService)
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
            .tag(AppRouter.Tab.settings)
        }
        .tint(AppColors.primary)
        .fullScreenCover(
            item: Binding(
                get: { unlockCoordinator.presentation },
                set: { newValue in
                    if newValue == nil {
                        unlockCoordinator.dismiss()
                    }
                }
            )
        ) { presentation in
            UnlockCelebrationView(
                wish: presentation.wish,
                imageData: presentation.imageData,
                conditionCount: presentation.conditionCount,
                onClaim: {
                    unlockCoordinator.claim()
                },
                onDismiss: {
                    unlockCoordinator.dismiss()
                }
            )
        }
        .appErrorAlert(error: $unlockCoordinator.error)
    }
}

#Preview {
    let container = AppContainer.preview()
    RootTabView(
        router: container.router,
        unlockCoordinator: container.unlockCoordinator,
        container: container
    )
}
