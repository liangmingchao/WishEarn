import Foundation

@MainActor
final class AppContainer {
    let dependencies: AppDependencies
    let router: AppRouter
    let store: SwiftDataStore

    let wishRepository: WishRepository
    let conditionRepository: ConditionRepository
    let progressRepository: ProgressRepository
    let unlockEventRepository: UnlockEventRepository
    let pausePeriodRepository: WishPausePeriodRepository

    init(
        dependencies: AppDependencies = .live,
        router: AppRouter? = nil,
        store: SwiftDataStore
    ) {
        self.dependencies = dependencies
        self.router = router ?? AppRouter()
        self.store = store
        self.wishRepository = SwiftDataWishRepository(store: store)
        self.conditionRepository = SwiftDataConditionRepository(store: store)
        self.progressRepository = SwiftDataProgressRepository(store: store)
        self.unlockEventRepository = SwiftDataUnlockEventRepository(store: store)
        self.pausePeriodRepository = SwiftDataWishPausePeriodRepository(store: store)
    }

    static func live() throws -> AppContainer {
        let container = try ModelContainerFactory.make()
        let store = SwiftDataStore(container: container)
        return AppContainer(store: store)
    }

    static func preview() -> AppContainer {
        do {
            let container = try ModelContainerFactory.make(inMemory: true)
            let store = SwiftDataStore(container: container)
            return AppContainer(dependencies: .preview, store: store)
        } catch {
            fatalError("无法创建预览数据库：\(error)")
        }
    }

    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(clock: dependencies.clock)
    }
}
