import UIKit
import UserNotifications

/// AppDelegate handles notification delegation and app lifecycle events.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var activityLogViewModel: ActivityLogViewModel?

    /// Called when the app finishes launching. Sets up notification delegate.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// Allows notifications to show as banners even when app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    /// Handles user interaction with notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        if identifier.contains("movement-reminder") {
            activityLogViewModel?.addReminderResponded()
            print("User responded to movement reminder")
        } else {
            print("Notification received with unknown identifier: \(identifier)")
        }
        completionHandler()
    }

    /// Called when the app becomes active.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // No longer log reminder responded here; only log when user taps notification
        print("App became active")
    }
}