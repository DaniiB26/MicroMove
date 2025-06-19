import Foundation
import SwiftData

class ActivityLogViewModel: ObservableObject {
    @Published var activityLogs: [ActivityLog] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchActivityLogs()
    }

    func fetchActivityLogs() {
        do {
            let descriptor = FetchDescriptor<ActivityLog>()
            activityLogs = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching activity logs: \(error)")
            activityLogs = []
        }
    }

    func addActivityLog(_ activityLog: ActivityLog) {
        do {
            try modelContext.insert(activityLog)
            fetchActivityLogs()
        } catch {
            print("Error inserting activity log: \(error)")
        }
    }

    func updateActivityLog(_ activityLog: ActivityLog) {
        do {
            try modelContext.save()
            fetchActivityLogs()
        } catch {
            print("Error updating activity log: \(error)")
        }
    }

    func deleteActivityLog(_ activityLog: ActivityLog) {
        do {
            modelContext.delete(activityLog)
            try modelContext.save()
            fetchActivityLogs()
        } catch {
            print("Error deleting activity log: \(error)")
        }
    }
}