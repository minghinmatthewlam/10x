import SwiftUI

struct GoalSetupView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Goals")
                .font(.tenxTitle)
                .foregroundStyle(Color.tenxTextPrimary)

            Text("Define up to three active goals. You can archive goals later.")
                .font(.tenxBody)
                .foregroundStyle(Color.tenxTextSecondary)

            List {
                ForEach(Array(viewModel.goalTitles.enumerated()), id: \.offset) { index, _ in
                    TextField("Goal \(index + 1)", text: $viewModel.goalTitles[index])
                        .textInputAutocapitalization(.sentences)
                }
                .onDelete(perform: viewModel.removeGoal)

                if viewModel.canAddGoal {
                    Button {
                        viewModel.addGoal()
                    } label: {
                        Label("Add Goal", systemImage: "plus")
                    }
                }
            }
            .listStyle(.plain)

            Spacer()
        }
        .padding(24)
        .background(Color.tenxBackground)
    }
}
