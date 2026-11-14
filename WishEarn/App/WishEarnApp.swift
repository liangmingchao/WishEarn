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

        do {
            let container = try AppContainer.live()
            container.performStartupRecovery()
            self.container = container
            // 只保留一个实例：设置页写入的对象必须就是根视图读取的对象，
            // 否则切换外观要等下次启动重新读 UserDefaults 才生效。
            self.appearanceSettings = container.appearanceSettings
            startupError = nil
        } catch {
            container = nil
            startupError = AppError.wrap(error)
            // 启动失败页没有设置入口，单独一份即可。
            self.appearanceSettings = AppearanceSettings()
        }
    }

    var body: some Scene {
        WindowGroup {
            AppearanceScope(settings: appearanceSettings) {
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
}

/// Applies the chosen appearance from inside a real `View` body.
///
/// SwiftUI does not track `@Observable` reads made in `App` / `Scene` builders,
/// so reading `settings.colorScheme` directly in `WishEarnApp.body` would only
/// pick up the new value on the next launch. Reading it here — inside a view's
/// body — makes the switch take effect immediately.
private struct AppearanceScope<Content: View>: View {
    let settings: AppearanceSettings
    private let content: Content

    init(settings: AppearanceSettings, @ViewBuilder content: () -> Content) {
        self.settings = settings
        self.content = content()
    }

    var body: some View {
        content.preferredColorScheme(settings.colorScheme)
    }
}
