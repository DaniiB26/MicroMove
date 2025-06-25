import SwiftUI

struct ActivityListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: ActivityLogViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.activityLogs.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { log in
                NavigationLink(destination: ActivityDetailView(viewModel: viewModel, activityLog: log)) {
                    ActivityRowView(activityLog: log)
                }
            }
        }
        .navigationTitle("Activity Log")
    }
}