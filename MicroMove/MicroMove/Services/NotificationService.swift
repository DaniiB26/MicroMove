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
    /// Removes only pending notifications with the given identifiers.
    func removePending(identifiers: [String], completion: (() -> Void)?)
    /// Retrieves all pending notification requests.
    func getPendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void)
}

/// Protocol to abstract UNUserNotificationCenter for dependency injection
protocol UserNotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {}

/// Concrete implementation of NotificationServiceProtocol using dependency injection
class NotificationService: NotificationServiceProtocol {
    private let center: UserNotificationCenterProtocol

    init(center: UserNotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorization(completion: ((Bool, Error?) -> Void)?) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            completion?(granted, error)
        }
    }
    func scheduleNotification(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger, completion: ((Error?) -> Void)?) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { error in
            completion?(error)
        }
    }
    func removeNotifications(identifiers: [String], completion: (() -> Void)?) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        completion?()
    }
    func removePending(identifiers: [String], completion: (() -> Void)?) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        completion?()
    }
    func getPendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}
