import SwiftUI
import SwiftData

struct DayFocusDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date
    @State private var entry: DayEntry?

    private let calendar = Calendar.current

    init(startDate: Date = .now) {
        _selectedDate = State(initialValue: Calendar.current.startOfDay(for: startDate))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            if let entry {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(entry.sortedFocuses) { focus in
                        HStack(spacing: 10) {
                            Circle()
                                .strokeBorder(
                                    focus.isCompleted ? AppColors.complete : AppColors.textMuted,
                                    lineWidth: 1.5
                                )
                                .background(
                                    Circle()
                                        .fill(focus.isCompleted ? AppColors.complete : Color.clear)
                                )
                                .frame(width: 18, height: 18)
                                .overlay {
                                    if focus.isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.tenxTinyBold)
                                            .foregroundStyle(AppColors.background)
                                    }
                                }

                            Text(focus.title)
                                .font(.tenxBody)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
            } else {
                Text("No focus set.")
                    .font(.tenxBody)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(24)
        .background(AppColors.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .simultaneousGesture(daySwipeGesture)
        .onAppear {
            loadEntry()
        }
        .onChange(of: selectedDate) { _, _ in
            loadEntry()
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                Button {
                    moveSelection(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.tenxIconMedium)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
                .opacity(canMoveBackward ? 1 : 0.3)
                .disabled(!canMoveBackward)

                Spacer()

                Text(formattedDate)
                    .font(.tenxTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button {
                    moveSelection(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.tenxIconMedium)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
                .opacity(canMoveForward ? 1 : 0.3)
                .disabled(!canMoveForward)
            }

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.tenxIconButton)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(AppColors.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }

    private var todayStart: Date {
        calendar.startOfDay(for: .now)
    }

    private var selectedStart: Date {
        calendar.startOfDay(for: selectedDate)
    }

    private var canMoveBackward: Bool {
        true
    }

    private var canMoveForward: Bool {
        selectedStart < todayStart
    }

    private func moveSelection(by delta: Int) {
        guard let newDate = calendar.date(byAdding: .day, value: delta, to: selectedStart) else { return }
        guard newDate <= todayStart else { return }
        selectedDate = newDate
    }

    private var daySwipeGesture: some Gesture {
        DragGesture(minimumDistance: 24, coordinateSpace: .local)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < -60 {
                    moveSelection(by: 1)
                } else if value.translation.width > 60 {
                    moveSelection(by: -1)
                }
            }
    }

    private func loadEntry() {
        let store = TenXStore(context: modelContext)
        entry = try? store.fetchDayEntry(dayKey: DayKey.make(for: selectedDate))
    }
}
