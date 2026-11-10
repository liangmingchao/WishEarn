import SwiftUI

#if DEBUG
import UIKit
#endif

@main
@MainActor
struct WishEarnApp: App {
    private let container: AppContainer?
    private let startupError: AppError?

    init() {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ui-testing-crop")
            || ProcessInfo.processInfo.arguments.contains("-ui-testing") {
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
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-ui-testing-crop") {
                WishPhotoCropView(
                    image: Self.uiTestCropImage,
                    onCrop: { _ in },
                    onCancel: {}
                )
            } else {
                rootView
            }
#else
            rootView
#endif
        }
    }

    @ViewBuilder
    private var rootView: some View {
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

#if DEBUG
    private static let uiTestCropImage: UIImage = {
        let size = CGSize(width: 1200, height: 900)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.systemIndigo.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor.systemYellow.setFill()
            context.fill(CGRect(x: 220, y: 160, width: 760, height: 580))

            UIColor.systemPink.setFill()
            context.fill(CGRect(x: 420, y: 300, width: 360, height: 300))
        }
    }()
#endif
}
