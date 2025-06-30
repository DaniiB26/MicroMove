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
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["movement-reminder-repeating", "movement-reminder-initial"])

        let inQuietHours = isInQuietHours()
        print("isInQuietHours: \(inQuietHours)")
        guard !inQuietHours else {
            print("Not scheduling notification: in quiet hours.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Move!"
        content.body = "Take a quick break and do a micro-workout."
        content.sound = .default

        let calendar = Calendar.current
        let now = Date()
        let interval = TimeInterval(userPreferencesViewModel.reminderInterval * 60)

        // Find the most recent activity log from today
        let todayStart = calendar.startOfDay(for: now)
        let todayLogs = activityLogViewModel.activityLogs
            .filter { $0.timestamp >= todayStart }
            .sorted { $0.timestamp > $1.timestamp }

        var firstFireDate: Date

        if let lastTodayLog = todayLogs.first {
            // There was activity today: schedule from last log + interval
            firstFireDate = lastTodayLog.timestamp.addingTimeInterval(interval)
            print("Scheduling from last activity log at \(lastTodayLog.timestamp)")
            // If the calculated fire date is in the past, schedule for now + interval
            if firstFireDate < now {
                firstFireDate = now.addingTimeInterval(interval)
            }
        } else {
            // No activity today: start from reminderTime or now if past reminder time
            let reminderTime = userPreferencesViewModel.reminderTime
            var nextReminder = calendar.date(
                bySettingHour: calendar.component(.hour, from: reminderTime),
                minute: calendar.component(.minute, from: reminderTime),
                second: 0,
                of: now
            ) ?? now
            
            if nextReminder < now {
                // If reminder time has passed today, start immediately (in next interval)
                firstFireDate = now.addingTimeInterval(interval)
                print("Reminder time passed, starting in \(interval/60) minutes")
            } else {
                // Reminder time hasn't passed yet today
                firstFireDate = nextReminder
                print("Scheduling from reminder time at \(firstFireDate)")
            }
        }

        let timeIntervalUntilFirst = firstFireDate.timeIntervalSince(now)

        // Schedule the first notification
        let firstTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilFirst, repeats: false)
        let firstRequest = UNNotificationRequest(
            identifier: "movement-reminder-initial",
            content: content,
            trigger: firstTrigger
        )
        UNUserNotificationCenter.current().add(firstRequest) { error in
            if let error = error {
                print("Failed to schedule initial notification: \(error)")
            } else {
                print("Initial notification scheduled successfully.")
            }
        }

        // Schedule repeating notifications every reminderInterval minutes
        let repeatingTrigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let repeatingRequest = UNNotificationRequest(
            identifier: "movement-reminder-repeating",
            content: content,
            trigger: repeatingTrigger
        )
        UNUserNotificationCenter.current().add(repeatingRequest) { error in
            if let error = error {
                print("Failed to schedule repeating notification: \(error)")
            } else {
                print("Repeating notification scheduled successfully.")
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
}