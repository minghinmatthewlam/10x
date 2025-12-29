import SwiftUI
import TenXShared

struct ThemePickerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    private var palette: ThemePalette { themeManager.theme.palette }

    var body: some View {
        List {
            ForEach(Theme.allCases) { option in
                Button {
                    themeManager.theme = option
                } label: {
                    HStack {
                        Text(option.label)
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        if option == themeManager.theme {
                            Image(systemName: "checkmark")
                                .foregroundStyle(palette.accent)
                        }
                    }
                }
                .listRowBackground(palette.surface)
            }
        }
        .navigationTitle("Style")
        .scrollContentBackground(.hidden)
        .background(palette.background)
        .toolbarBackground(palette.background, for: .navigationBar)
        .tint(palette.accent)
    }
}
