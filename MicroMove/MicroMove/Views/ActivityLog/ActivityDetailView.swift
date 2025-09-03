import SwiftUI

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityLogViewModel
    let activityLog: ActivityLog

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Activity type with icon
            HStack(spacing: 12) {
                Image(systemName: iconName(for: activityLog.type))
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text(activityLog.type.displayName)
                    .font(.title)
                    .bold()
                Spacer()
            }
            Divider()
            // Details section
            VStack(alignment: .leading, spacing: 12) {
                Text(activityLog.activityDesc)
                    .font(.body)
                    .foregroundColor(.secondary)
                Label {
                    Text(activityLog.timestamp.formatted(date: .abbreviated, time: .shortened))
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                }
                Label {
                    Text(activityLog.dayContext.rawValue.capitalized)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                }
                Label {
                    Text("\(activityLog.duration) min")
                } icon: {
                    Image(systemName: "timer")
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    viewModel.deleteActivityLog(activityLog)
                    dismiss()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .padding()
        .navigationTitle("Activity Detail")
    }

    // Helper to pick an icon for each activity type
    private func iconName(for type: ActivityLog.ActivityType) -> String {
        switch type {
        case .appOpen: return "app.badge"
        case .exerciseStart: return "figure.walk"
        case .exerciseComplete: return "checkmark.circle"
        case .reminderTriggered: return "bell"
        case .reminderResponded: return "bell.fill"
        case .inactivityDetected: return "zzz"
        case .triggerEvaluation:  return "bell.badge"
        }
    }
}
