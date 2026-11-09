import Foundation

@MainActor
final class AppContainer {
    let dependencies: AppDependencies
    let router: AppRouter
    let store: SwiftDataStore
    let imageStorageService: ImageStorageService
    let dataExportService: DataExportService

    let wishRepository: WishRepository
    let conditionRepository: ConditionRepository
    let progressRepository: ProgressRepository
    let unlockEventRepository: UnlockEventRepository
    let pausePeriodRepository: WishPausePeriodRepository
    let lifecycleService: WishLifecycleServicing
    let conditionLifecycleService: ConditionLifecycleServicing
    let progressRecordService: ProgressRecordServicing
    let streakCalculator: StreakCalculator
    let progressCalculator: ProgressCalculator
    let wishProgressService: WishProgressService
    let unlockService: WishUnlockServicing
    let unlockCoordinator: UnlockCoordinator

    init(
        dependencies: AppDependencies = .live,
        router: AppRouter? = nil,
        store: SwiftDataStore,
        imageStorageService: ImageStorageService = LocalImageStorageService()
    ) {
        self.dependencies = dependencies
        self.router = router ?? AppRouter()
        self.store = store
        self.imageStorageService = imageStorageService
        self.wishRepository = SwiftDataWishRepository(
            store: store,
            imageStorage: imageStorageService
        )
        self.conditionRepository = SwiftDataConditionRepository(store: store)
        self.progressRepository = SwiftDataProgressRepository(store: store)
        self.unlockEventRepository = SwiftDataUnlockEventRepository(store: store)
        self.pausePeriodRepository = SwiftDataWishPausePeriodRepository(store: store)
        self.dataExportService = DataExportService(
            wishRepository: self.wishRepository,
            conditionRepository: self.conditionRepository,
            progressRepository: self.progressRepository,
            unlockEventRepository: self.unlockEventRepository,
            pausePeriodRepository: self.pausePeriodRepository,
            clock: dependencies.clock
        )
        self.lifecycleService = WishLifecycleService(
            wishRepository: self.wishRepository,
            pausePeriodRepository: self.pausePeriodRepository,
            clock: dependencies.clock
        )
        let streakCalculator = StreakCalculator(clock: dependencies.clock)
        let progressCalculator = ProgressCalculator(streakCalculator: streakCalculator)
        let wishProgressService = WishProgressService(
            conditionRepository: self.conditionRepository,
            progressRepository: self.progressRepository,
            pausePeriodRepository: self.pausePeriodRepository,
            progressCalculator: progressCalculator
        )

        self.streakCalculator = streakCalculator
        self.progressCalculator = progressCalculator
        self.wishProgressService = wishProgressService

        let unlockCoordinator = UnlockCoordinator(
            wishRepository: self.wishRepository,
            conditionRepository: self.conditionRepository,
            imageStorage: imageStorageService,
            lifecycleService: self.lifecycleService
        )
        self.unlockCoordinator = unlockCoordinator
        self.unlockService = WishUnlockService(
            wishRepository: self.wishRepository,
            unlockEventRepository: self.unlockEventRepository,
            progressService: wishProgressService,
            clock: dependencies.clock,
            unlockPublisher: unlockCoordinator
        )
        self.conditionLifecycleService = ConditionLifecycleService(
            wishRepository: self.wishRepository,
            conditionRepository: self.conditionRepository,
            clock: dependencies.clock,
            unlockService: self.unlockService
        )
        self.progressRecordService = ProgressRecordService(
            conditionRepository: self.conditionRepository,
            progressRepository: self.progressRepository,
            clock: dependencies.clock,
            unlockService: self.unlockService
        )
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
            let previewImageDirectory = FileManager.default.temporaryDirectory
                .appendingPathComponent("WishEarnPreviewImages-\(UUID().uuidString)", isDirectory: true)
            let imageStorage = LocalImageStorageService(baseDirectory: previewImageDirectory)
            return AppContainer(
                dependencies: .preview,
                store: store,
                imageStorageService: imageStorage
            )
        } catch {
            fatalError("无法创建预览数据库：\(error)")
        }
    }

    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            progressRepository: progressRepository,
            clock: dependencies.clock
        )
    }

    func makeWishListViewModel() -> WishListViewModel {
        WishListViewModel(
            wishRepository: wishRepository,
            wishProgressService: wishProgressService,
            imageStorage: imageStorageService,
            lifecycleService: lifecycleService
        )
    }

    func makeWishEditorViewModel(wish: Wish? = nil) -> WishEditorViewModel {
        WishEditorViewModel(
            lifecycleService: lifecycleService,
            imageStorage: imageStorageService,
            clock: dependencies.clock,
            editingWish: wish
        )
    }

    func makeWishDetailViewModel(wish: Wish) -> WishDetailViewModel {
        WishDetailViewModel(
            wish: wish,
            wishRepository: wishRepository,
            conditionLifecycleService: conditionLifecycleService,
            wishProgressService: wishProgressService,
            lifecycleService: lifecycleService,
            imageStorage: imageStorageService
        )
    }

    func makeConditionEditorViewModel(
        wishID: UUID,
        condition: Condition?,
        sortOrder: Int
    ) -> ConditionEditorViewModel {
        ConditionEditorViewModel(
            wishID: wishID,
            lifecycleService: conditionLifecycleService,
            condition: condition,
            sortOrder: sortOrder
        )
    }

    func makeConditionDetailViewModel(condition: Condition) -> ConditionDetailViewModel {
        ConditionDetailViewModel(
            condition: condition,
            service: progressRecordService
        )
    }

    func makeAchievementsViewModel() -> AchievementsViewModel {
        AchievementsViewModel(
            wishRepository: wishRepository,
            wishProgressService: wishProgressService,
            progressRepository: progressRepository,
            imageStorage: imageStorageService
        )
    }

    func makeRecordEditorViewModel(
        condition: Condition,
        record: ProgressRecord?
    ) -> RecordEditorViewModel {
        RecordEditorViewModel(
            condition: condition,
            record: record,
            service: progressRecordService,
            clock: dependencies.clock
        )
    }
}
