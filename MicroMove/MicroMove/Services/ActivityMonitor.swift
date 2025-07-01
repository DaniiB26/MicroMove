import UserNotifications

@MainActor
class ActivityMonitor {
    private let activityLogViewModel: ActivityLogViewModel
    private let userPreferencesViewModel: UserPreferencesViewModel

    init(activityLogViewModel: ActivityLogViewModel, userPreferencesViewModel: UserPreferencesViewModel) {
        self.activityLogViewModel = activityLogViewModel
        self.userPreferencesViewModel = userPreferencesViewModel
    }
    
    func timeSinceLastActivity() -> TimeInterval {
        guard let lastActivity = getLastActivity() else {
            return TimeInterval.greatestFiniteMagnitude
        }

        return Date().timeIntervalSince(lastActivity.timestamp)
    }

    func getLastActivity() -> ActivityLog? {
        // Use the new method from ActivityLogViewModel for clarity
        return activityLogViewModel.lastExerciseActivityLog()
    }

    func shouldScheduleReminder() -> Bool {
        let inactiveTime = timeSinceLastActivity()
        let reminderInterval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)

        return inactiveTime >= reminderInterval
    }

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

        // Handle quiet hours that may span midnight
        if quietStartInMinutes < quietEndInMinutes {
            // Quiet hours do NOT span midnight
        return currentTimeInMinutes >= quietStartInMinutes && currentTimeInMinutes <= quietEndInMinutes
        } else {
            // Quiet hours DO span midnight
            return currentTimeInMinutes >= quietStartInMinutes || currentTimeInMinutes <= quietEndInMinutes
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Notification permission granted")
            }
            else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }

    func checkAndScheduleReminder() {
        print("checkAndScheduleReminder called")
        // Remove any existing scheduled reminders to avoid duplicates
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["movement-reminder-repeating", "movement-reminder-repeating-repeat"])

        let inQuietHours = isInQuietHours()
        print("isInQuietHours: \(inQuietHours)")
        guard !inQuietHours else {
            print("Not scheduling notification: in quiet hours.")
            return
        }

        // Prepare notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.body = "Take a quick break and do a micro-workout."
        content.sound = .default

        // Calculate the interval in seconds from user preferences (minutes to seconds)
        let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)

        // Get the last activity timestamp (optional)
        let timeAtLastActivity = activityLogViewModel.lastExerciseActivityLog()?.timestamp
        let userReminderTime = userPreferencesViewModel.reminderTime

        // Determine the anchor time: the most recent of last activity or reminder time
        var anchorTime: Date
        if let lastActivity = timeAtLastActivity, lastActivity > userReminderTime {
            anchorTime = lastActivity
            print("Anchor time is last activity: \(anchorTime)")
        } else {
            anchorTime = userReminderTime
            print("Anchor time is user reminder time: \(anchorTime)")
        }

        // Calculate the next reminder time: interval minutes after anchor time, but in the future
        var nextReminderTime = anchorTime.addingTimeInterval(interval)
        while nextReminderTime < Date() {
            nextReminderTime = nextReminderTime.addingTimeInterval(interval)
        }
        let timeUntilNext = max(nextReminderTime.timeIntervalSinceNow, 1)
        print("Next reminder will fire in \(timeUntilNext) seconds (", nextReminderTime, ") and repeat every \(interval) seconds.")

        // Schedule the first notification (non-repeating)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilNext, repeats: false)
        let request = UNNotificationRequest(
            identifier: "movement-reminder-repeating",
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
        // Schedule repeating notifications every interval after the first one
        let repeatingTrigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let repeatingRequest = UNNotificationRequest(
            identifier: "movement-reminder-repeating-repeat",
            content: content,
            trigger: repeatingTrigger
        )
        UNUserNotificationCenter.current().add(repeatingRequest) { error in
            if let error = error {
                print("Failed to schedule repeating notification: \(error)")
            } else {
                print("Repeating notification scheduled every \(interval) seconds.")
            }
        }
    }

    func detectAndLogInactivity() {
        let inactiveTime = timeSinceLastActivity()
        let reminderInterval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)
        // Log inactivity if user has missed 2 reminder intervals
        if inactiveTime >= reminderInterval * 2 {
            activityLogViewModel.addInactivityDetected(inactiveTime: inactiveTime)
        }
    }

    func transformFromDateToSeconds(date: Date) -> TimeInterval {
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return TimeInterval(hour * 3600 + minutes * 60)
    }

    /// Cancels all pending reminder notifications and schedules a new repeating notification interval minutes from now.
    func resetReminderFromNow() {
        print("resetReminderFromNow called")
        // Remove all pending reminder notifications (both identifiers)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["movement-reminder-repeating", "movement-reminder-repeating-repeat"])

        // Prepare notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.body = "Take a quick break and do a micro-workout."
        content.sound = .default

        // Calculate the interval in seconds from user preferences (minutes to seconds)
        let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)

        // Schedule a new repeating notification interval minutes from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(
            identifier: "movement-reminder-repeating",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule repeating notification from now: \(error)")
            } else {
                print("Repeating notification scheduled from now (interval: \(interval) seconds).")
            }
        }
    }
}