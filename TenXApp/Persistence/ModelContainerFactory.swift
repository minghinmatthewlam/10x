import Foundation
import SwiftData
import TenXShared

enum ModelContainerFactory {
    static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([TenXGoal.self, DayEntry.self, DailyFocus.self])

        let migrationPlan = TenXMigrationPlan.self

        do {
            let groupContainer: ModelConfiguration.GroupContainer
            if inMemory {
                groupContainer = .none
            } else if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID) != nil {
                groupContainer = .identifier(SharedConstants.appGroupID)
            } else {
                groupContainer = .none
            }

            let config = ModelConfiguration(schema: schema,
                                            isStoredInMemoryOnly: inMemory,
                                            groupContainer: groupContainer)

            return try ModelContainer(for: schema,
                                      migrationPlan: migrationPlan,
                                      configurations: [config])
        } catch {
            do {
                let fallbackConfig = ModelConfiguration(schema: schema,
                                                       isStoredInMemoryOnly: inMemory)
                return try ModelContainer(for: schema,
                                          configurations: [fallbackConfig])
            } catch {
                let memoryConfig = ModelConfiguration(schema: schema,
                                                      isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema,
                                          configurations: [memoryConfig])
            }
        }
    }
}
