import Foundation
import SwiftData
@testable import TenX

enum TestContainerFactory {
    static func makeContext() -> ModelContext {
        let container = ModelContainerFactory.make(inMemory: true)
        return ModelContext(container)
    }
}
