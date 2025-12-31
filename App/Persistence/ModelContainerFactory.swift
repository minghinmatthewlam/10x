import Foundation
import SwiftData
import TenXShared

enum ModelContainerFactory {
    static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([DayEntry.self, DailyFocus.self])

        do {
            let groupContainer: ModelConfiguration.GroupContainer
            if inMemory {
                groupContainer = .none
            } else if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID) != nil {
                groupContainer = .identifier(SharedConstants.appGroupID)
            } else {
                groupContainer = .none
            }

            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory,
                groupContainer: groupContainer
            )

            return try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            do {
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: inMemory
                )
                return try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfig]
                )
            } catch {
                let memoryConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                do {
                    return try ModelContainer(
                        for: schema,
                        configurations: [memoryConfig]
                    )
                } catch {
                    fatalError("Failed to create SwiftData container: \(error)")
                }
            }
        }
    }
}
