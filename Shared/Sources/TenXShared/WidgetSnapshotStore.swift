import Foundation
import os

public final class WidgetSnapshotStore {
    private let fileManager: FileManager
    private let appGroupID: String
    private let filename: String
    private let logger = Logger(subsystem: "com.matthewlam.tenx", category: "WidgetSnapshotStore")

    public init(fileManager: FileManager = .default,
                appGroupID: String = SharedConstants.appGroupID,
                filename: String = SharedConstants.widgetSnapshotFilename) {
        self.fileManager = fileManager
        self.appGroupID = appGroupID
        self.filename = filename
    }

    public func load() -> WidgetSnapshot? {
        guard let url = snapshotURL() else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(WidgetSnapshot.self, from: data)
    }

    public func save(_ snapshot: WidgetSnapshot) throws {
        guard let url = snapshotURL() else {
            throw WidgetSnapshotStoreError.missingAppGroupContainer
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)
        try data.write(to: url, options: [.atomic])
    }

    private func snapshotURL() -> URL? {
        if let base = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return base.appendingPathComponent(filename)
        }
        logger.error("Missing app group container URL for \(self.appGroupID, privacy: .public)")
#if DEBUG
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
#else
        return nil
#endif
    }
}

public enum WidgetSnapshotStoreError: Error {
    case missingAppGroupContainer
}
