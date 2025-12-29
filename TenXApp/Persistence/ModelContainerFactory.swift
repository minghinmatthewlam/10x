import Foundation
import SwiftData
import TenXShared

enum ModelContainerFactory {
    static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([TenXGoal.self, DayEntry.self, DailyFocus.self])

        let migrationPlan = TenXMigrationPlan.self

        do {
            let groupContainer: ModelConfiguration.GroupContainer = inMemory ? .none : .identifier(SharedConstants.appGroupID)
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
                                          migrationPlan: migrationPlan,
                                          configurations: [fallbackConfig])
            } catch {
                fatalError("Failed to create SwiftData container: \(error)")
            }
        }
    }
}
