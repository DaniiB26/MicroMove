import SwiftUI

struct ActivityListView: View {
    @ObservedObject var viewModel: ActivityLogViewModel
    @State private var showDeleteAll = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Page background
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if viewModel.activityLogs.isEmpty {
                            EmptyStateView(
                                title: "No activity yet",
                                subtitle: "Your logs will appear here."
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(
                                viewModel.activityLogs.sorted(by: { $0.timestamp > $1.timestamp }),
                                id: \.id
                            ) { log in
                                NavigationLink {
                                    ActivityDetailView(viewModel: viewModel, activityLog: log)
                                } label: {
                                    ActivityRowView(activityLog: log)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(.plain)       // keep the card appearance
                                .contentShape(Rectangle()) // whole card tappable
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Activity Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) { showDeleteAll = true } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .confirmationDialog("Delete all logs?", isPresented: $showDeleteAll) {
                Button("Delete All", role: .destructive) {
                    viewModel.deleteAllLogs()
                }
            }
            .onAppear { viewModel.fetchActivityLogs() }
        }
    }
}