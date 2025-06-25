import SwiftUI

struct ActivityRowView: View {
    let activityLog: ActivityLog

    var body: some View {
        HStack(spacing: 12) {
            // Icon for activity type
            Image(systemName: iconName(for: activityLog.type))
                .foregroundColor(.accentColor)
            Text(activityLog.type.rawValue.capitalized)
            Spacer()
            Text(activityLog.timestamp.formatted(date: .abbreviated, time: .omitted))
                .foregroundColor(.secondary)
            Text(activityLog.dayContext.rawValue.capitalized)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activityLog.type.rawValue.capitalized), \(activityLog.timestamp.formatted(date: .abbreviated, time: .omitted)), \(activityLog.dayContext.rawValue.capitalized), \(activityLog.duration) min")
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
        }
    }
}