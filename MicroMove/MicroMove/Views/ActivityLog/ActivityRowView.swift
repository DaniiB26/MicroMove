import SwiftUI

struct ActivityRowView: View {
    let activityLog: ActivityLog

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: activityLog.type))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconTint(for: activityLog.type))
                .frame(width: 36, height: 36)
                .background(iconTint(for: activityLog.type).opacity(0.12))
                .clipShape(Circle())

            // Main info
            VStack(alignment: .leading, spacing: 2) {
                Text(activityLog.type.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text(activityLog.dayContext.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(activityLog.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .background(Color.white) // white card on gray page
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func iconName(for type: ActivityLog.ActivityType) -> String {
        switch type {
        case .appOpen:            return "rectangle.and.text.magnifyingglass"
        case .exerciseStart:      return "figure.walk"
        case .exerciseComplete:   return "checkmark.seal.fill"
        case .reminderTriggered:  return "bell"
        case .reminderResponded:  return "bell.badge.fill"
        case .inactivityDetected: return "zzz"
        case .triggerEvaluation:  return "bell.badge"
        }
    }

    private func iconTint(for type: ActivityLog.ActivityType) -> Color {
        switch type {
        case .appOpen:            return .blue
        case .exerciseStart:      return .orange
        case .exerciseComplete:   return .green
        case .reminderTriggered:  return .purple
        case .reminderResponded:  return .indigo
        case .inactivityDetected: return .gray
        case .triggerEvaluation:  return .teal
        }
    }
}
