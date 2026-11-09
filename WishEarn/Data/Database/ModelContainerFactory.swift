import Foundation
import SwiftData

enum ModelContainerFactory {
    static let schema = Schema([
        WishEntity.self,
        ConditionEntity.self,
        ProgressRecordEntity.self,
        UnlockEventEntity.self,
        WishPausePeriodEntity.self
    ])

    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: WishEarnMigrationPlan.self,
            configurations: [configuration]
        )
    }

    static func make(storeURL: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: WishEarnMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
