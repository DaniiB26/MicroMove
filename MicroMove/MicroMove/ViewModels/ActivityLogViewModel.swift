import Foundation
import SwiftData

/// ViewModel for managing ActivityLog CRUD operations and state.
@MainActor
class ActivityLogViewModel: ObservableObject {
    /// The list of all activity logs, published for UI updates.
    @Published var activityLogs: [ActivityLog] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchActivityLogs()
    }

    /// Fetches all activity logs from the data store.
    func fetchActivityLogs() {
        do {
            let descriptor = FetchDescriptor<ActivityLog>()
            activityLogs = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error fetching activity logs: \(error.localizedDescription)"
            activityLogs = []
        }
    }

    /// Adds a new activity log to the data store and updates the list.
    func addActivityLog(_ activityLog: ActivityLog) {
        modelContext.insert(activityLog)
        activityLogs.append(activityLog)
    }

    /// Saves changes to an existing activity log. Call after modifying an activity log's properties.
    func updateActivityLog(_ activityLog: ActivityLog) {
        do {
            try modelContext.save()
            // Optionally update the item in the array if needed
        } catch {
            errorMessage = "Error updating activity log: \(error.localizedDescription)"
        }
    }

    /// Deletes an activity log from the data store and updates the list.
    func deleteActivityLog(_ activityLog: ActivityLog) {
        do {
            modelContext.delete(activityLog)
            try modelContext.save()
            activityLogs.removeAll { $0.id == activityLog.id }
        } catch {
            errorMessage = "Error deleting activity log: \(error.localizedDescription)"
        }
    }
}