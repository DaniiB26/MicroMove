import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var activityLogViewModel: ActivityLogViewModel?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // This method lets notifications show as banners even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier.contains("movement-reminder") {
            activityLogViewModel?.addReminderResponded()
            print("User responded to movement reminder")
        }
        completionHandler()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // No longer log reminder responded here; only log when user taps notification
        print("App became active")
    }
}