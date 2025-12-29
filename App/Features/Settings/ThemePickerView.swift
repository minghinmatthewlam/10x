import SwiftUI
import TenXShared

struct ThemePickerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        List {
            ForEach(Theme.allCases) { option in
                Button {
                    themeManager.theme = option
                } label: {
                    HStack {
                        Text(option.label)
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                        if option == themeManager.theme {
                            Image(systemName: "checkmark")
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
                .listRowBackground(theme.surface)
            }
        }
        .navigationTitle("Style")
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .toolbarBackground(theme.background, for: .navigationBar)
        .tint(theme.accent)
    }
}
