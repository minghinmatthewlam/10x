import SwiftData

enum TenXMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TenXSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum TenXSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TenXGoal.self, DayEntry.self, DailyFocus.self]
    }
}
