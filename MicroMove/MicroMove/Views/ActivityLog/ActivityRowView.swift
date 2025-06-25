import SwiftUI

struct ActivityRowView: View {
    let activityLog: ActivityLog

    var body: some View {
        HStack {
            Text(activityLog.type.rawValue.capitalized)
            Spacer()
            Text(activityLog.timestamp.formatted(date: .abbreviated, time: .omitted))
            Text(activityLog.dayContext.rawValue.capitalized)
            Spacer()
            Text("\(activityLog.duration) min")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activityLog.type.rawValue.capitalized), \(activityLog.timestamp.formatted(date: .abbreviated, time: .omitted)), \(activityLog.dayContext.rawValue.capitalized), \(activityLog.duration) min")
    }
}