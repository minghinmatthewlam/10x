import SwiftUI
import SwiftData

struct DailySetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Int?

    @StateObject private var viewModel: DailySetupViewModel

    let onComplete: () -> Void

    init(initialDrafts: [TenXStore.FocusDraft] = [], onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: DailySetupViewModel(initialDrafts: initialDrafts))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What would make\ntoday a 10x day?")
                            .font(.tenxHero)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineSpacing(4)
                    }

                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.drafts.enumerated()), id: \.offset) { index, _ in
                            FocusInputRow(
                                draft: $viewModel.drafts[index],
                                placeholder: placeholder(for: index),
                                isFocused: focusedField == index
                            ) {
                                focusedField = nil
                            }
                            .focused($focusedField, equals: index)
                        }
                    }

                    Spacer(minLength: 32)

                    Button("Begin") {
                        startDay()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                    .opacity(viewModel.hasValidFocus ? 1 : 0.4)
                    .disabled(!viewModel.hasValidFocus)
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
            .background(AppColors.background)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.tenxIconButton)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .toolbarBackground(AppColors.background, for: .navigationBar)
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
        .onAppear {
            focusedField = 0
        }
    }

    private func placeholder(for index: Int) -> String {
        switch index {
        case 0: return "Your most important focus..."
        case 1: return "What else matters today?"
        default: return "One more thing..."
        }
    }

    private func startDay() {
        let store = TenXStore(context: modelContext)
        let todayKey = DayKey.make()
        if viewModel.startDay(store: store, todayKey: todayKey) {
            Haptics.mediumImpact()
            onComplete()
            dismiss()
        }
    }
}
