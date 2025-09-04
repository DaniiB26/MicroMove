import UIKit
import UserNotifications

/// AppDelegate handles notification delegation and app lifecycle events.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var activityLogViewModel: ActivityLogViewModel?
    var activityMonitor: ActivityMonitor?
    var routineNotificationCoordinator: RoutineNotificationCoordinator?
    // Map of unique occurrence key -> logID. Key format: "<identifier>|<deliveryTime>"
    private var routineLogIDsByOccurrenceKey: [String: UUID] = [:]

    // MARK: - Helpers
    private func makeOccurrenceKey(identifier: String, date: Date) -> String {
        "\(identifier)|\(date.timeIntervalSince1970)"
    }

    /// Attempts to resolve a TriggerType for a request using userInfo first, then the coordinator.
    private func resolveTriggerType(for request: UNNotificationRequest) -> TriggerType? {
        if let raw = request.content.userInfo[NotificationUserInfoKeys.triggerType] as? String,
           let type = TriggerType(rawValue: raw) {
            return type
        }
        return routineNotificationCoordinator?.trigger(forNotificationIdentifier: request.identifier)?.triggerType
    }

    /// Called when the app finishes launching. Sets up notification delegate.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        print("[AppDelegate] App launched, notification delegate set.")
        return true
    }

    /// Allows notifications to show as banners even when app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier
        print("[AppDelegate] Notification will present: \(identifier)")
        let occurrenceKey = makeOccurrenceKey(identifier: identifier, date: notification.date)
        if identifier.contains(NotificationIdentifiers.movementReminder) {
            // Log movement reminder delivered (triggered)
            DispatchQueue.main.async {
                if let log = self.activityLogViewModel?.addReminderTriggered(at: notification.date) {
                    print("[AppDelegate] Logged movement reminder triggered id=\(log.id)")
                }
            }
        } else if let trigger = routineNotificationCoordinator?.trigger(forNotificationIdentifier: identifier) {
            DispatchQueue.main.async {
                if let log = self.activityLogViewModel?.logTriggerEvaluation(trigger: trigger, responded: false) {
                    self.routineLogIDsByOccurrenceKey[occurrenceKey] = log.id
                    print("[AppDelegate] Logged trigger evaluation (willPresent): \(trigger.triggerType.rawValue) id=\(log.id)")
                }
            }
        } else {
            // Fallback: resolve from userInfo or coordinator
            if let type = resolveTriggerType(for: notification.request) {
                DispatchQueue.main.async {
                    if let log = self.activityLogViewModel?.logTriggerEvaluation(triggerType: type, responded: false) {
                        self.routineLogIDsByOccurrenceKey[occurrenceKey] = log.id
                        print("[AppDelegate] Fallback logged trigger evaluation (willPresent): \(type.rawValue) id=\(log.id)")
                    }
                }
            } else {
                print("[AppDelegate] Notification willPresent has unknown identifier and no trigger info: \(identifier)")
            }
        }
        completionHandler([.banner, .sound])
    }

    /// Handles user interaction with notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let occurrenceKey = makeOccurrenceKey(identifier: identifier, date: response.notification.date)
        // Delegate business logic to ActivityMonitor and ActivityLogViewModel
        if identifier.contains(NotificationIdentifiers.movementReminder) {
            DispatchQueue.main.async {
                self.activityLogViewModel?.addReminderResponded()
                print("[AppDelegate] User responded to movement reminder")
                // Chain next reminder if still inactive
                self.activityMonitor?.handlePossibleContinuedInactivity()
            }
        } else if let trigger = routineNotificationCoordinator?.trigger(forNotificationIdentifier: identifier) {
            if let logID = routineLogIDsByOccurrenceKey[occurrenceKey] {
                DispatchQueue.main.async {
                    self.activityLogViewModel?.markTriggerLogResponded(logID: logID)
                    print("[AppDelegate] Marked trigger evaluation responded for id=\(logID)")
                }
            } else {
                // No prior willPresent (likely delivered in background). Create responded log now.
                DispatchQueue.main.async {
                    if let log = self.activityLogViewModel?.logTriggerEvaluation(trigger: trigger, responded: true) {
                        print("[AppDelegate] Logged trigger evaluation (responded immediately): id=\(log.id)")
                    }
                }
            }
        } else {
            // Fallback: resolve from userInfo or coordinator
            if let type = resolveTriggerType(for: response.notification.request) {
                if let logID = routineLogIDsByOccurrenceKey[occurrenceKey] {
                    DispatchQueue.main.async {
                        self.activityLogViewModel?.markTriggerLogResponded(logID: logID)
                        print("[AppDelegate] Fallback marked responded for id=\(logID)")
                    }
                } else {
                    DispatchQueue.main.async {
                        if let log = self.activityLogViewModel?.logTriggerEvaluation(triggerType: type, responded: true) {
                            print("[AppDelegate] Fallback logged responded for type=\(type.rawValue), id=\(log.id)")
                        }
                    }
                }
            } else {
                print("[AppDelegate] Notification received with unknown identifier: \(identifier)")
            }
        }
        completionHandler()
    }

    /// Called when the app becomes active. Checks and schedules inactivity reminders.
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("[AppDelegate] App became active")
        // First, log any delivered movement reminders before we potentially clear them
        logPendingDeliveredMovementReminders { [weak self] in
            // Delegate to ActivityMonitor for reminder logic after logging
            self?.activityMonitor?.handlePossibleContinuedInactivity()
        }
        // Log any delivered routine notifications that were not responded to
        logPendingDeliveredRoutineNotifications()
    }

    /// Logs "not responded" for any delivered routine notifications we haven't recorded yet.
    private func logPendingDeliveredRoutineNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            for item in notifications {
                let identifier = item.request.identifier
                // Skip movement reminders; those are handled separately
                if identifier.contains(NotificationIdentifiers.movementReminder) { continue }

                let occurrenceKey = "\(identifier)|\(item.date.timeIntervalSince1970)"
                if self.routineLogIDsByOccurrenceKey[occurrenceKey] != nil { continue }

                // Resolve trigger type
                guard let type = self.resolveTriggerType(for: item.request) else { continue }

                DispatchQueue.main.async {
                    if let log = self.activityLogViewModel?.logTriggerEvaluation(triggerType: type, responded: false) {
                        self.routineLogIDsByOccurrenceKey[occurrenceKey] = log.id
                        print("[AppDelegate] Logged non-responded delivered notification: \(type.rawValue), id=\(log.id)")
                    }
                }
            }
        }
    }

    /// Logs delivered movement reminders ("Reminder Triggered") then calls completion.
    private func logPendingDeliveredMovementReminders(completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let movementDelivered = notifications.filter { $0.request.identifier.contains(NotificationIdentifiers.movementReminder) }
            if movementDelivered.isEmpty {
                completion?()
                return
            }
            DispatchQueue.main.async {
                movementDelivered.forEach { item in
                    if let log = self.activityLogViewModel?.addReminderTriggered(at: item.date) {
                        print("[AppDelegate] Logged delivered movement reminder at \(item.date) id=\(log.id)")
                    }
                }
                completion?()
            }
        }
    }
}
