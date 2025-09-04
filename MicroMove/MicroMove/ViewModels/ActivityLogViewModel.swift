import Foundation
import SwiftData
import UserNotifications

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
            print("[ActivityLogViewModel] Successfully fetched activity logs.")
        } catch {
            errorMessage = "Error fetching activity logs: \(error.localizedDescription)"
            activityLogs = []
        }
    }

    /// Adds a new activity log to the data store and updates the list.
    func addActivityLog(_ activityLog: ActivityLog) {
        modelContext.insert(activityLog)
        activityLogs.append(activityLog)
        print("[ActivityLogViewModel] Added activity log: \(activityLog.activityDesc)")
    }

    /// Saves changes to an existing activity log. Call after modifying an activity log's properties.
    func updateActivityLog(_ activityLog: ActivityLog) {
        do {
            try modelContext.save()
            print("[ActivityLogViewModel] Updated activity log: \(activityLog.activityDesc)")
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
            print("[ActivityLogViewModel] Deleted activity log: \(activityLog.activityDesc)")
        } catch {
            errorMessage = "Error deleting activity log: \(error.localizedDescription)"
        }
    }

    func deleteAllLogs() {
        do {
            let descriptor = FetchDescriptor<ActivityLog>()
            let all = try modelContext.fetch(descriptor)
            all.forEach { modelContext.delete($0) }
            try modelContext.save()
            activityLogs.removeAll()
            print("[ActivityLogViewModel] Deleted ALL activity logs.")
        } catch {
            errorMessage = "Error deleting all activity logs: \(error.localizedDescription)"
        }
    }

    /// Determines the time-of-day context for a given date.
    private func getDayContext(for date: Date) -> ActivityLog.ActivityDayContext {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }

    /// Logs an app open event.
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

    /// Logs the start of an exercise.
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

    /// Logs the completion of an exercise.
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

    /// Logs when a reminder is triggered.
    func addReminderTriggered() -> ActivityLog {
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
        return log
    }

    /// Logs when a reminder is triggered at a specific time (e.g., delivery time).
    func addReminderTriggered(at date: Date) -> ActivityLog {
        let log = ActivityLog(
            id: UUID(),
            timestamp: date,
            type: .reminderTriggered,
            activityDesc: "Reminder Triggered",
            duration: 0,
            dayContext: getDayContext(for: date)
        )
        addActivityLog(log)
        return log
    }

    /// Logs when a reminder is responded to by the user.
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

    /// Logs when inactivity is detected.
    func addInactivityDetected(inactiveTime: TimeInterval) {
        let now = Date()
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .inactivityDetected,
            activityDesc: "User was inactive for \(inactiveTime) seconds",
            duration: 0,
            dayContext: getDayContext(for: now)
        )
        addActivityLog(log)
    }

    /// Returns the most recent exercise activity log (start or complete)
    func lastExerciseActivityLog() -> ActivityLog? {
        let relevantTypes: [ActivityLog.ActivityType] = [.exerciseStart, .exerciseComplete]
        return activityLogs
            .filter { relevantTypes.contains($0.type) }
            .sorted { $0.timestamp > $1.timestamp }
            .first
    }

    /// Logs evaluation of a routine trigger and returns the created log.
    func logTriggerEvaluation(trigger: RoutineTrigger, responded: Bool) -> ActivityLog {
        let now = Date()
        let desc = "Trigger evaluated: \(trigger.triggerType.label)\(trigger.exercise != nil ? " for \(trigger.exercise!.name)" : "")"
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .triggerEvaluation,
            activityDesc: desc,
            duration: 0,
            dayContext: getDayContext(for: now),
            triggerType: trigger.triggerType,
            responded: responded
        )
        addActivityLog(log)
        return log
    }

    /// Logs evaluation using just a TriggerType when full trigger is unavailable.
    func logTriggerEvaluation(triggerType: TriggerType, responded: Bool, exerciseName: String? = nil) -> ActivityLog {
        let now = Date()
        let namePart = exerciseName.map { " for \($0)" } ?? ""
        let desc = "Trigger evaluated: \(triggerType.label)\(namePart)"
        let log = ActivityLog(
            id: UUID(),
            timestamp: now,
            type: .triggerEvaluation,
            activityDesc: desc,
            duration: 0,
            dayContext: getDayContext(for: now),
            triggerType: triggerType,
            responded: responded
        )
        addActivityLog(log)
        return log
    }

    /// Marks a previously created trigger-evaluation log as responded.
    func markTriggerLogResponded(logID: UUID) {
        guard let idx = activityLogs.firstIndex(where: { $0.id == logID }) else { return }
        activityLogs[idx].responded = true
        updateActivityLog(activityLogs[idx])
    }
}
