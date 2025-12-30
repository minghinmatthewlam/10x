import SwiftUI
import TenXShared
import WidgetKit
#if canImport(UIKit)
import UIKit
#endif

struct DiagnosticsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var didCopy = false

    var body: some View {
        List {
            Section("App Group") {
                infoRow(label: "Group ID", value: SharedConstants.appGroupID)
                infoRow(label: "Container URL", value: AppGroup.containerURL?.path ?? "Unavailable")
                infoRow(label: "Theme (shared)", value: sharedTheme ?? "nil")
            }

            Section("Widget Snapshot") {
                infoRow(label: "Snapshot path", value: snapshotURL?.path ?? "Unavailable")
                infoRow(label: "Last refresh", value: lastSnapshotRefresh ?? "Unknown")
                VStack(alignment: .leading, spacing: 8) {
                    Text("Snapshot JSON")
                        .font(.tenxSmall)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(snapshotJSON)
                        .font(.tenxCaption)
                        .foregroundStyle(AppColors.textPrimary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(AppColors.surface)
            }

            Section("Actions") {
                Button("Copy diagnostics") {
                    copyDiagnostics()
                }
                .listRowBackground(AppColors.surface)

                Button("Force widget refresh") {
                    let store = TenXStore(context: modelContext)
                    WidgetSnapshotService(store: store).refreshSnapshot(todayKey: DayKey.make())
                }
                .listRowBackground(AppColors.surface)

                Button("Reload widget timelines") {
                    WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.widgetKind)
                }
                .listRowBackground(AppColors.surface)
            }
        }
        .navigationTitle("Diagnostics")
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .tint(AppColors.accent)
        .alert("Copied", isPresented: $didCopy) {
            Button("OK") { didCopy = false }
        } message: {
            Text("Diagnostics copied to clipboard.")
        }
    }

    private var sharedTheme: String? {
        UserDefaults(suiteName: SharedConstants.appGroupID)?
            .string(forKey: UserDefaultsKeys.theme)
    }

    private var snapshotURL: URL? {
        AppGroup.containerURL?.appendingPathComponent(SharedConstants.widgetSnapshotFilename)
    }

    private var snapshot: WidgetSnapshot? {
        WidgetSnapshotStore().load()
    }

    private var lastSnapshotRefresh: String? {
        guard let snapshot else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: snapshot.generatedAt)
    }

    private var snapshotJSON: String {
        guard let url = snapshotURL,
              let data = try? Data(contentsOf: url),
              let string = String(data: data, encoding: .utf8) else {
            return "No snapshot file found."
        }
        return string
    }

    private var diagnosticsText: String {
        let themeValue = sharedTheme ?? "nil"
        let containerPath = AppGroup.containerURL?.path ?? "Unavailable"
        let snapshotPath = snapshotURL?.path ?? "Unavailable"
        let lastRefresh = lastSnapshotRefresh ?? "Unknown"
        return """
        App Group ID: \(SharedConstants.appGroupID)
        App Group Container: \(containerPath)
        Theme (shared): \(themeValue)
        Snapshot Path: \(snapshotPath)
        Snapshot Last Refresh: \(lastRefresh)
        Snapshot JSON:
        \(snapshotJSON)
        """
    }

    private func copyDiagnostics() {
#if canImport(UIKit)
        UIPasteboard.general.string = diagnosticsText
        didCopy = true
#endif
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowBackground(AppColors.surface)
    }
}
