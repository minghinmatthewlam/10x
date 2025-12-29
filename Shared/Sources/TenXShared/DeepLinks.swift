import Foundation

public enum DeepLinks {
    public static let scheme = "tenx"

    public enum Host: String, CaseIterable {
        case home
        case setup
        case settings
    }

    public static func url(for host: Host) -> URL {
        guard let url = URL(string: "\(scheme)://\(host.rawValue)") else {
            preconditionFailure("Invalid deep link host: \(host)")
        }
        return url
    }
}
