import SwiftUI

struct NotificationTimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        DatePicker("Reminder Time", selection: Binding(get: {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return Calendar.current.date(from: components) ?? .now
        }, set: { newDate in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
            hour = components.hour ?? hour
            minute = components.minute ?? minute
        }), displayedComponents: .hourAndMinute)
    }
}
