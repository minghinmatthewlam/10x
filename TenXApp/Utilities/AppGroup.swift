import Foundation
import TenXShared

enum AppGroup {
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID)
    }
}
