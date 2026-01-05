import SwiftUI
import TenXShared

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
