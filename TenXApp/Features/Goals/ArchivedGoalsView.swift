import SwiftUI
import SwiftData

struct ArchivedGoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TenXGoal> { $0.archivedAt != nil }, sort: [SortDescriptor(\.createdAt)])
    private var archivedGoals: [TenXGoal]

    @ObservedObject var viewModel: GoalsViewModel

    var body: some View {
        List {
            ForEach(archivedGoals, id: \.uuid) { goal in
                HStack {
                    Text(goal.title)
                    Spacer()
                    Button("Unarchive") {
                        let store = TenXStore(context: modelContext)
                        viewModel.unarchiveGoal(goal, store: store)
                        WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Archived Goals")
    }
}
