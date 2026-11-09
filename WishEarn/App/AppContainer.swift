import Foundation
import OSLog

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
    private(set) var startupRecoveryReport: UnlockRecoveryReport?
    private let logger = Logger(
        subsystem: "com.wishearn.app",
        category: "UnlockRecovery"
    )

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
            unlockService: self.unlockService,
            unlockFailureReporter: unlockCoordinator
        )
        self.progressRecordService = ProgressRecordService(
            conditionRepository: self.conditionRepository,
            progressRepository: self.progressRepository,
            clock: dependencies.clock,
            unlockService: self.unlockService,
            unlockFailureReporter: unlockCoordinator
        )
    }

    /// 启动时修复解锁事件与心愿状态的不一致。
    ///
    /// 恢复只补写状态，不会删除/覆盖历史事件；部分失败通过报告与日志
    /// 观察，不阻断 App 启动。
    func performStartupRecovery() {
        do {
            let report = try unlockService.recoverUnlockConsistency()
            startupRecoveryReport = report

            logger.info(
                "解锁恢复完成：恢复 \(report.restoredWishIDs.count) 个，新增解锁 \(report.newlyUnlockedWishIDs.count) 个，缺少事件 \(report.missingEventWishIDs.count) 个，孤立事件 \(report.orphanedEventWishIDs.count) 个，失败 \(report.failures.count) 个"
            )

            if !report.missingEventWishIDs.isEmpty {
                logger.warning(
                    "发现已解锁/已完成但缺少解锁事件的心愿：\(report.missingEventWishIDs.map(\.uuidString).joined(separator: ","), privacy: .public)"
                )
            }
            if !report.orphanedEventWishIDs.isEmpty {
                logger.warning(
                    "发现没有对应心愿的解锁事件：\(report.orphanedEventWishIDs.map(\.uuidString).joined(separator: ","), privacy: .public)"
                )
            }

            if let failure = report.failures.first {
                let message = report.failures.count == 1
                    ? "启动恢复失败：\(failure.message)"
                    : "\(report.failures.count) 个心愿的启动恢复失败：\(failure.message)"
                unlockCoordinator.error = .unexpected(message)
            }
        } catch {
            let appError = AppError.wrap(error)
            startupRecoveryReport = nil
            logger.error(
                "解锁恢复失败：\(appError.message, privacy: .public)"
            )
            unlockCoordinator.error = appError
        }
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
            progressRepository: progressRepository,
            wishProgressService: wishProgressService,
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
            imageStorage: imageStorageService,
            progressRepository: progressRepository,
            clock: dependencies.clock
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
