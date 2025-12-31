import SwiftUI

struct NotificationTimePickerView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @State private var isPickerPresented = false

    var body: some View {
        Button {
            isPickerPresented = true
        } label: {
            HStack {
                Text("Morning reminder")
                    .font(.tenxBody)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text(formattedTime)
                    .font(.tenxBody)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(AppColors.surface)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPickerPresented) {
            TimePickerSheet(hour: $hour, minute: $minute)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }

    private var formattedTime: String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? .now
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hour: Int
    @Binding var minute: Int

    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var isAM: Bool

    init(hour: Binding<Int>, minute: Binding<Int>) {
        _hour = hour
        _minute = minute
        let initialHour = hour.wrappedValue
        let adjustedHour = initialHour.isMultiple(of: 12) ? 12 : initialHour % 12
        _selectedHour = State(initialValue: adjustedHour)
        _selectedMinute = State(initialValue: minute.wrappedValue)
        _isAM = State(initialValue: initialHour < 12)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Morning reminder")
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(.tenxBody)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 0) {
                Picker("Hour", selection: $selectedHour) {
                    ForEach(1...12, id: \.self) { value in
                        Text("\(value)")
                            .font(.tenxBody)
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { value in
                        Text(String(format: "%02d", value))
                            .font(.tenxBody)
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Period", selection: $isAM) {
                    Text("AM").tag(true)
                    Text("PM").tag(false)
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 180)
            .onChange(of: selectedHour) { _, _ in updateTime() }
            .onChange(of: selectedMinute) { _, _ in updateTime() }
            .onChange(of: isAM) { _, _ in updateTime() }
        }
        .padding(.vertical, 12)
        .background(AppColors.background)
    }

    private func updateTime() {
        var computedHour = selectedHour % 12
        if !isAM {
            computedHour += 12
        }
        hour = computedHour
        minute = selectedMinute
    }
}
