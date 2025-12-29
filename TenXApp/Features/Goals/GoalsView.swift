import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TenXGoal> { $0.archivedAt == nil }, sort: [SortDescriptor(\.createdAt)])
    private var activeGoals: [TenXGoal]

    @StateObject private var viewModel = GoalsViewModel()
    @State private var showingEditor = false

    var body: some View {
        List {
            Section("Active Goals") {
                ForEach(activeGoals, id: \.uuid) { goal in
                    Text(goal.title)
                        .swipeActions {
                            Button(role: .destructive) {
                                let store = TenXStore(context: modelContext)
                                viewModel.archiveGoal(goal, store: store)
                                WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                        }
                }
            }

            NavigationLink("Archived Goals") {
                ArchivedGoalsView(viewModel: viewModel)
            }
        }
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(activeGoals.count >= AppConstants.maxActiveGoals)
            }
        }
        .sheet(isPresented: $showingEditor) {
            GoalEditorView { title in
                let store = TenXStore(context: modelContext)
                viewModel.createGoal(title: title, store: store)
                WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
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
}
