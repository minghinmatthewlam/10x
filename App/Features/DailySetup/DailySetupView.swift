import SwiftUI
import SwiftData

struct DailySetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<TenXGoal> { $0.archivedAt == nil }, sort: [SortDescriptor(\.createdAt)])
    private var activeGoals: [TenXGoal]

    @StateObject private var viewModel: DailySetupViewModel

    let onComplete: () -> Void

    init(initialDrafts: [TenXStore.FocusDraft] = [], onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: DailySetupViewModel(initialDrafts: initialDrafts))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Set Today’s Focus")
                        .font(.tenxTitle)
                        .foregroundStyle(Color.tenxTextPrimary)

                    ForEach(Array(viewModel.drafts.enumerated()), id: \.offset) { index, _ in
                        FocusInputRow(draft: $viewModel.drafts[index],
                                      goals: activeGoals,
                                      index: index)
                    }

                    Button("Start Day") {
                        startDay()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(24)
            }
            .background(Color.tenxBackground)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .alert("Oops", isPresented: Binding(get: {
            viewModel.errorMessage != nil
        }, set: { isPresented in
            if !isPresented { viewModel.errorMessage = nil }
        })) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func startDay() {
        let store = TenXStore(context: modelContext)
        let todayKey = DayKey.make()
        if viewModel.startDay(store: store, todayKey: todayKey) {
            onComplete()
            dismiss()
        }
    }
}
