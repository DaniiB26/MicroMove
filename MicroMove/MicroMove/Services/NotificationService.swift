import Foundation
import UserNotifications

/// Protocol for notification scheduling/removal (for testability and modularity)
protocol NotificationServiceProtocol {
    /// Requests notification authorization from the user.
    func requestAuthorization(completion: ((Bool, Error?) -> Void)?)
    /// Schedules a notification with the given identifier, content, and trigger.
    func scheduleNotification(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger, completion: ((Error?) -> Void)?)
    /// Removes pending and delivered notifications with the given identifiers.
    func removeNotifications(identifiers: [String], completion: (() -> Void)?)
    /// Retrieves all pending notification requests.
    func getPendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void)
}

/// Concrete implementation of NotificationServiceProtocol using UNUserNotificationCenter
class NotificationService: NotificationServiceProtocol {
    func requestAuthorization(completion: ((Bool, Error?) -> Void)?) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            completion?(granted, error)
        }
    }
    func scheduleNotification(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger, completion: ((Error?) -> Void)?) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            completion?(error)
        }
    }
    func removeNotifications(identifiers: [String], completion: (() -> Void)?) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        completion?()
    }
    func getPendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}
