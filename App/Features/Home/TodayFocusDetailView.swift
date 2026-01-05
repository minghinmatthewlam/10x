import SwiftUI

struct TodayFocusDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: DayEntry?
    let date: Date

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
    }

    private var header: some View {
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

            Text(formattedDate)
                .font(.tenxTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
