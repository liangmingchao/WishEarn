import Observation

@MainActor
@Observable
final class AppRouter {
    enum Tab: Hashable {
        case wishes
        case today
        case achievements
        case settings
    }

    var selectedTab: Tab = .wishes
}
