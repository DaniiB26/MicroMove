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
        do {
            try modelContext.save()
            activityLogs.append(activityLog)
        } catch {
            errorMessage = "Error saving new activity log: \(error.localizedDescription)"
        }
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

    func getLastActivity() -> ActivityLog? {
        return activityLogs.last
    }

    private func getDayContext(for date: Date) -> ActivityLog.ActivityDayContext {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }

    func addAppOpen() {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: Date(),
            type: .appOpen,
            activityDesc: "App Open",
            duration: 0,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }

    func addExerciseStart(exercise: Exercise) {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .exerciseStart,
            activityDesc: "Exercise: \(exercise.name) started",
            duration: 0,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }

    func addExerciseComplete(exercise: Exercise) {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .exerciseComplete,
            activityDesc: "Exercise: \(exercise.name) completed",
            duration: exercise.duration,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }

    func addReminderTriggered() {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .reminderTriggered,
            activityDesc: "Reminder Triggered",
            duration: 0,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }

    func addReminderResponded() {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .reminderResponded,
            activityDesc: "Reminder Responded",
            duration: 0,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }

    func addInactivityDetected() {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .inactivityDetected,
            activityDesc: "Inactivity Detected",
            duration: 0,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }
}