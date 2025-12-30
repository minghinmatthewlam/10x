import SwiftUI

struct WeeklyProgressGridView: View {
    let days: [WeeklyProgressDay]
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("Weekly Progress")
                    .font(.tenxTitle)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("Success: \(successRate)%")
                    .font(.tenxSmall)
                    .foregroundStyle(theme.textSecondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                ForEach(days) { day in
                    VStack(spacing: 8) {
                        Text(dayLabel(for: day.date))
                            .font(.tenxCaption)
                            .foregroundStyle(theme.textSecondary)

                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(statusColor(for: day))
                                .frame(height: 40)

                            if day.total > 0 {
                                if day.maintainsStreak {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.white)
                                } else if day.completed > 0 {
                                    Text("\(day.completed)/\(day.total)")
                                        .font(.tenxCaption)
                                        .foregroundStyle(Color.white)
                                } else {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Color.white.opacity(0.7))
                                }
                            }
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                LegendItem(color: Color.green, label: "Success")
                LegendItem(color: Color.orange, label: "Partial")
                LegendItem(color: theme.textMuted, label: "Missed")
            }
        }
        .padding(20)
        .background(theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var successRate: Int {
        let daysWithGoals = days.filter { $0.total > 0 }
        guard !daysWithGoals.isEmpty else { return 0 }
        let successfulDays = daysWithGoals.filter { $0.maintainsStreak }.count
        return Int((Double(successfulDays) / Double(daysWithGoals.count)) * 100)
    }

    private func statusColor(for day: WeeklyProgressDay) -> Color {
        guard day.total > 0 else { return theme.surface }
        if day.maintainsStreak {
            return Color.green
        }
        if day.completed > 0 {
            return Color.orange
        }
        return theme.textMuted
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.tenxCaption)
                .foregroundStyle(theme.textSecondary)
        }
    }
}
