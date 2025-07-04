import UserNotifications

/// ActivityMonitor is responsible for tracking user inactivity and scheduling movement reminders.
@MainActor
class ActivityMonitor {
    private let activityLogViewModel: ActivityLogViewModel
    private let userPreferencesViewModel: UserPreferencesViewModel
    
    /// Notification identifiers used for movement reminders
    private let reminderNotificationIdentifier = "movement-reminder"

    init(activityLogViewModel: ActivityLogViewModel, userPreferencesViewModel: UserPreferencesViewModel) {
        self.activityLogViewModel = activityLogViewModel
        self.userPreferencesViewModel = userPreferencesViewModel
    }
    
    /// Returns the time interval since the last exercise activity.
    func timeSinceLastActivity() -> TimeInterval {
        guard let lastActivity = getLastActivity() else {
            return TimeInterval.greatestFiniteMagnitude
        }
        return Date().timeIntervalSince(lastActivity.timestamp)
    }

    /// Returns the most recent exercise activity log (start or complete).
    func getLastActivity() -> ActivityLog? {
        return activityLogViewModel.lastExerciseActivityLog()
    }

    /// Determines if a reminder should be scheduled based on inactivity.
    func shouldScheduleReminder() -> Bool {
        let inactiveTime = timeSinceLastActivity()
        let reminderInterval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        return inactiveTime >= reminderInterval
    }

    /// Returns true if the current time is within user-defined quiet hours.
    func isInQuietHours() -> Bool {
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
            return currentTimeInMinutes >= quietStartInMinutes && currentTimeInMinutes <= quietEndInMinutes
        } else {
            return currentTimeInMinutes >= quietStartInMinutes || currentTimeInMinutes <= quietEndInMinutes
        }
    }

    /// Requests notification permission from the user.
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }

    /// Schedules a one-time reminder notification after the user-defined interval from the last activity.
    func checkAndScheduleReminder() {
        print("checkAndScheduleReminder called")
        // Remove any existing scheduled reminders to avoid duplicates
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier])
        let inQuietHours = isInQuietHours()
        print("isInQuietHours: \(inQuietHours)")
        guard !inQuietHours else {
            print("Not scheduling notification: in quiet hours.")
            return
        }
        let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        let anchorTime = getLastActivity()?.timestamp ?? userPreferencesViewModel.reminderTime
        var nextReminderTime = anchorTime.addingTimeInterval(interval)
        while nextReminderTime < Date() {
            nextReminderTime = nextReminderTime.addingTimeInterval(interval)
        }
        let timeUntilNext = max(nextReminderTime.timeIntervalSinceNow, 1)
        print("Next reminder will fire in \(timeUntilNext) seconds (\(nextReminderTime)).")
        let content = makeReminderNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilNext, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminderNotificationIdentifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification scheduled for \(nextReminderTime)")
            }
        }
    }

    /// Cancels all pending reminder notifications and schedules a new one-time notification interval minutes from now.
    func resetReminderFromNow() {
        print("resetReminderFromNow called")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderNotificationIdentifier])
        let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        let content = makeReminderNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminderNotificationIdentifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification from now: \(error)")
            } else {
                print("Notification scheduled from now (interval: \(interval) seconds).")
            }
        }
    }

    /// Logs inactivity if the user has missed two reminder intervals.
    func detectAndLogInactivity() {
        let inactiveTime = timeSinceLastActivity()
        let reminderInterval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        if inactiveTime >= reminderInterval * 2 {
            activityLogViewModel.addInactivityDetected(inactiveTime: inactiveTime)
        }
    }

    /// Helper to create the notification content for movement reminders.
    private func makeReminderNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.body = "Take a quick break and do a micro-workout."
        content.sound = .default
        return content
    }

    func transformFromDateToSeconds(date: Date) -> TimeInterval {
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return TimeInterval(hour * 3600 + minutes * 60)
    }
}