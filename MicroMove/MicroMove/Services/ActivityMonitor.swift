import Foundation
import UserNotifications

/// ActivityMonitor: Handles inactivity detection and reminder scheduling.
@MainActor
class ActivityMonitor {
    private let activityLogViewModel: ActivityLogViewModel
    private let userPreferencesViewModel: UserPreferencesViewModel
    private let reminderNotificationIdentifier = "movement-reminder"

    init(activityLogViewModel: ActivityLogViewModel, userPreferencesViewModel: UserPreferencesViewModel) {
        self.activityLogViewModel = activityLogViewModel
        self.userPreferencesViewModel = userPreferencesViewModel
        requestNotificationPermission()
    }

    /// Request notification permission from the user.
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("[ActivityMonitor] Notification permission granted.")
            } else if let error = error {
                print("[ActivityMonitor] Notification permission denied: \(error.localizedDescription)")
            }
        }
    }

    /// Call this after any user activity (exercise, app open, etc.)
    func resetInactivityReminder() {
        print("[ActivityMonitor] resetInactivityReminder called at \(Date())")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [reminderNotificationIdentifier])
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("[ActivityMonitor] Pending notifications after removal: \(requests.map { $0.identifier })")
        }
        if !isInQuietHours() {
            scheduleInactivityReminder()
        } else {
            print("[ActivityMonitor] Not scheduling inactivity reminder: in quiet hours.")
        }
    }

    /// Schedules a local notification for inactivity after the user-defined interval.
    private func scheduleInactivityReminder() {
        let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        let now = Date()
        let calendar = Calendar.current

        // If no activity, or last activity is from a previous day, schedule for the next interval boundary
        let lastActivity = activityLogViewModel.lastExerciseActivityLog()
        var triggerTime: TimeInterval

        if lastActivity == nil || !calendar.isDate(lastActivity!.timestamp, inSameDayAs: now) {
            // No activity today (either never or last was yesterday or earlier)
            let components = calendar.dateComponents([.hour, .minute], from: now)
            let minutesSinceMidnight = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            let intervalMinutes = userPreferencesViewModel.reminderInterval
            let nextBoundary = ((minutesSinceMidnight / intervalMinutes) + 1) * intervalMinutes
            let minutesUntilNext = nextBoundary - minutesSinceMidnight
            triggerTime = TimeInterval(minutesUntilNext * 60)
            print("[ActivityMonitor] No activity today. Scheduling first reminder in \(minutesUntilNext) minutes (at next interval boundary).")
        } else {
            // Last activity was today, schedule after the usual interval
            triggerTime = interval
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.body = "You've been inactive for a while. Let's get moving!"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        let request = UNNotificationRequest(identifier: reminderNotificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[ActivityMonitor] Failed to schedule inactivity reminder: \(error)")
            } else {
                print("[ActivityMonitor] Inactivity reminder scheduled in \(triggerTime) seconds.")
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("[ActivityMonitor] Pending notifications after scheduling: \(requests.map { $0.identifier })")
                }
            }
        }
    }

    /// Checks inactivity and schedules a reminder if the user has been inactive for the full interval and it's not quiet hours.
    func checkAndScheduleReminder() {
        print("[ActivityMonitor] checkAndScheduleReminder called at \(Date())")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [reminderNotificationIdentifier])
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("[ActivityMonitor] Pending notifications after removal: \(requests.map { $0.identifier })")
        }
        if shouldSendReminder() {
            scheduleInactivityReminder()
        } else {
            print("[ActivityMonitor] No reminder scheduled: either not inactive long enough or in quiet hours.")
        }
    }

    /// Returns true if the user has been inactive for the full interval and it's not quiet hours.
    private func shouldSendReminder() -> Bool {
        let inactiveTime = timeSinceLastActivity()
        let reminderInterval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        let inQuietHours = isInQuietHours()
        print("[ActivityMonitor] Inactive for \(inactiveTime) seconds. Reminder interval: \(reminderInterval) seconds. In quiet hours: \(inQuietHours)")
        return inactiveTime >= reminderInterval && !inQuietHours
    }

    /// Returns the time interval since the last exercise activity.
    private func timeSinceLastActivity() -> TimeInterval {
        guard let lastActivity = activityLogViewModel.lastExerciseActivityLog() else {
            return TimeInterval.greatestFiniteMagnitude
        }
        return Date().timeIntervalSince(lastActivity.timestamp)
    }

    /// Returns true if the current time is within user-defined quiet hours.
    private func isInQuietHours() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let quietStartHour = calendar.component(.hour, from: userPreferencesViewModel.quietHoursStart)
        let quietStartMinute = calendar.component(.minute, from: userPreferencesViewModel.quietHoursStart)
        let quietEndHour = calendar.component(.hour, from: userPreferencesViewModel.quietHoursEnd)
        let quietEndMinute = calendar.component(.minute, from: userPreferencesViewModel.quietHoursEnd)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        let quietStartInMinutes = quietStartHour * 60 + quietStartMinute
        let quietEndInMinutes = quietEndHour * 60 + quietEndMinute
        if quietStartInMinutes < quietEndInMinutes {
            return currentTimeInMinutes >= quietStartInMinutes && currentTimeInMinutes < quietEndInMinutes
        } else {
            // Quiet hours cross midnight
            return currentTimeInMinutes >= quietStartInMinutes || currentTimeInMinutes < quietEndInMinutes
        }
    }

    /// Call this from AppDelegate when app enters foreground.
    func handleAppLifecycleEvent() {
        checkAndScheduleReminder()
    }

    /// Logs inactivity if the user has missed two reminder intervals.
    func detectAndLogInactivity() {
        let inactiveTime = timeSinceLastActivity()
        let reminderInterval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        if inactiveTime >= reminderInterval * 2 {
            activityLogViewModel.addInactivityDetected(inactiveTime: inactiveTime)
        }
    }

    /// Call this after a reminder is delivered or app becomes active to chain reminders at interval boundaries.
    func handlePossibleContinuedInactivity() {
        // If user is still inactive (no activity today), schedule next reminder at next interval boundary
        let now = Date()
        let calendar = Calendar.current
        let lastActivity = activityLogViewModel.lastExerciseActivityLog()
        if lastActivity == nil || !calendar.isDate(lastActivity!.timestamp, inSameDayAs: now) {
            // No activity today, already handled by scheduleInactivityReminder
            resetInactivityReminder()
        } else {
            // Last activity was today, check if enough time has passed since last activity
            let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
            let timeSinceLast = now.timeIntervalSince(lastActivity!.timestamp)
            if timeSinceLast >= interval {
                // Still inactive, schedule at next interval boundary
                resetInactivityReminder()
            } else {
                // User became active, do not schedule
                print("[ActivityMonitor] User became active, not scheduling next reminder.")
            }
        }
    }

    func transformFromDateToSeconds(date: Date) -> TimeInterval {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return TimeInterval(hour * 3600 + minutes * 60)
    }
}