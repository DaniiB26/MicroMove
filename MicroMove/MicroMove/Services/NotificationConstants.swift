import Foundation

/// Centralized constants for local notifications.
enum NotificationIdentifiers {
    /// Identifier used for inactivity movement reminders.
    static let movementReminder = "movement-reminder"
    /// Prefix used for grouping notifications per trigger in Notification Center.
    static let triggerThreadPrefix = "trigger-"
}

/// Keys used in `UNNotificationContent.userInfo` for routine trigger metadata.
enum NotificationUserInfoKeys {
    static let triggerID = "triggerID"
    static let triggerType = "triggerType"
}

