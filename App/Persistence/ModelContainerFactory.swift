import Foundation
import SwiftData
import os
import TenXShared

enum ModelContainerFactory {
    private static let logger = Logger(subsystem: "com.matthewlam.tenx", category: "ModelContainerFactory")

    static let isRunningInMemoryOnly = "tenx.runningInMemoryOnly"

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

            let container = try ModelContainer(
                for: schema,
                configurations: [config]
            )
            UserDefaults.standard.set(false, forKey: isRunningInMemoryOnly)
            return container
        } catch {
            logger.error("App Group container failed: \(error.localizedDescription, privacy: .public)")
            do {
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: inMemory
                )
                let container = try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfig]
                )
                UserDefaults.standard.set(false, forKey: isRunningInMemoryOnly)
                return container
            } catch {
                logger.critical("Default container failed, falling back to in-memory: \(error.localizedDescription, privacy: .public)")
                UserDefaults.standard.set(true, forKey: isRunningInMemoryOnly)
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
