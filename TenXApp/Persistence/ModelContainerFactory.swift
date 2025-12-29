import Foundation
import SwiftData
import TenXShared

enum ModelContainerFactory {
    static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([TenXGoal.self, DayEntry.self, DailyFocus.self])

        let storeURL: URL? = {
            guard !inMemory else { return nil }
            guard let base = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
            ) else { return nil }
            return base.appendingPathComponent("tenx.store")
        }()

        let migrationPlan = TenXMigrationPlan.self

        do {
            let config = ModelConfiguration(schema: schema,
                                            url: storeURL,
                                            isStoredInMemoryOnly: inMemory)

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
