import SwiftUI

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: ActivityLogViewModel
    @Environment(\.dismiss) private var dismiss
    let activityLog: ActivityLog

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(activityLog.type.rawValue.capitalized)
                    .font(.title)
                    .bold()
                Spacer()
            }
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(activityLog.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.body)

                Text(activityLog.dayContext.rawValue.capitalized)
                    .font(.body)

                Text("\(activityLog.duration) min")
                    .font(.body)
            }   
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete") {
                    Image(systemName: "trash")
                        .accessibilityLabel("Delete Activity Log")
                    viewModel.deleteActivityLog(activityLog)
                    dismiss()
                }
            }
        }
        .padding()
        .navigationTitle("Activity Detail")
    }
}