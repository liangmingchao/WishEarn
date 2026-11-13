import SwiftUI

@main
@MainActor
struct WishEarnApp: App {
    private let container: AppContainer?
    private let startupError: AppError?
    private let appearanceSettings: AppearanceSettings

    init() {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            let container = AppContainer.preview()
            container.performStartupRecovery()
            self.container = container
            self.appearanceSettings = container.appearanceSettings
            startupError = nil
            return
        }
#endif

        self.appearanceSettings = AppearanceSettings()

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
                .preferredColorScheme(appearanceSettings.colorScheme)
            } else {
                ErrorStateView(
                    title: "启动失败",
                    message: startupError?.message ?? "无法初始化本地数据库。"
                )
                .appScreenBackground()
                .preferredColorScheme(appearanceSettings.colorScheme)
            }
        }
    }
}
