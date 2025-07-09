import UIKit
import UserNotifications

/// AppDelegate handles notification delegation and app lifecycle events.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var activityLogViewModel: ActivityLogViewModel?
    var activityMonitor: ActivityMonitor?

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
        print("[AppDelegate] Notification will present: \(notification.request.identifier)")
        completionHandler([.banner, .sound])
    }

    /// Handles user interaction with notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        if identifier.contains("movement-reminder") {
            activityLogViewModel?.addReminderResponded()
            print("[AppDelegate] User responded to movement reminder")
            // Chain next reminder if still inactive
            activityMonitor?.handlePossibleContinuedInactivity()
        } else {
            print("[AppDelegate] Notification received with unknown identifier: \(identifier)")
        }
        completionHandler()
    }

    /// Called when the app becomes active. Checks and schedules inactivity reminders.
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("[AppDelegate] App became active")
        activityMonitor?.handlePossibleContinuedInactivity()
    }
}
