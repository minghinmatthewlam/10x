import SwiftUI

enum YearProgressPalette {
    static let success = Color(red: 0.30, green: 0.62, blue: 1.00)
    static let incomplete = Color(red: 0.18, green: 0.38, blue: 0.78)
    static let emptyToday = Color(red: 0.16, green: 0.27, blue: 0.48)
    static let emptyPast = Color(red: 0.06, green: 0.13, blue: 0.25)
    static let future = Color(red: 0.17, green: 0.17, blue: 0.18)
}

extension YearDayStatus {
    var color: Color {
        switch self {
        case .success:
            return YearProgressPalette.success
        case .incomplete:
            return YearProgressPalette.incomplete
        case .emptyToday:
            return YearProgressPalette.emptyToday
        case .emptyPast:
            return YearProgressPalette.emptyPast
        case .future:
            return YearProgressPalette.future
        }
    }
}
