import SwiftUI

@main
@MainActor
struct WishEarnApp: App {
    private let container: AppContainer?
    private let startupError: AppError?

    init() {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            let container = AppContainer.preview()
            container.performStartupRecovery()
            self.container = container
            startupError = nil
            return
        }
#endif

        do {
            let container = try AppContainer.live()
            container.performStartupRecovery()
            self.container = container
            startupError = nil
        } catch {
            container = nil
            startupError = AppError.wrap(error)
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container {
                RootTabView(
                    router: container.router,
                    unlockCoordinator: container.unlockCoordinator,
                    container: container
                )
            } else {
                ErrorStateView(
                    title: "启动失败",
                    message: startupError?.message ?? "无法初始化本地数据库。"
                )
                .appScreenBackground()
            }
        }
    }
}
