import Foundation
import TenXShared

enum AppRoute {
    case home
    case setup
    case settings
}

enum AppRouter {
    static func route(for url: URL) -> AppRoute? {
        guard url.scheme == DeepLinks.scheme else { return nil }
        guard let host = url.host, let routeHost = DeepLinks.Host(rawValue: host) else { return nil }
        switch routeHost {
        case .home: return .home
        case .setup: return .setup
        case .settings: return .settings
        }
    }
}
