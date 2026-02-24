import Foundation
import UIKit

@MainActor
final class SignificantTimeChangeListener {
    private var observers: [NSObjectProtocol] = []

    init(onChange: @escaping () -> Void) {
        let center = NotificationCenter.default

        observers.append(center.addObserver(forName: UIApplication.significantTimeChangeNotification,
                                            object: nil,
                                            queue: .main) { _ in
            onChange()
        })

        observers.append(center.addObserver(forName: .NSCalendarDayChanged,
                                            object: nil,
                                            queue: .main) { _ in
            onChange()
        })

        observers.append(center.addObserver(forName: .NSSystemTimeZoneDidChange,
                                            object: nil,
                                            queue: .main) { _ in
            onChange()
        })
    }

    deinit {
        let center = NotificationCenter.default
        observers.forEach { center.removeObserver($0) }
    }
}
