import Foundation
import SwiftData

/// Represents a log entry for user activity in the app.
@Model
final class ActivityLog {
    /// Unique identifier for the log entry.
    let id: UUID
    /// Timestamp of the activity.
    var timestamp: Date
    /// Type of activity performed.
    var type: ActivityType
    /// Activity description.
    var activityDesc: String
    /// Duration of the activity in minutes.
    var duration: Int
    /// Context of the day when the activity occurred.
    var dayContext: ActivityDayContext
    /// The type of trigger associated with this log, if any.
    var triggerType: TriggerType?
    /// Indicates whether the user responded to the trigger, if applicable.
    var responded: Bool?

    /// Types of activities that can be logged.
    enum ActivityType: String, Codable {
        case appOpen
        case exerciseStart
        case exerciseComplete
        case reminderTriggered
        case reminderResponded
        case inactivityDetected
        case triggerEvaluation

        /// A more human-friendly label for UI
        var displayName: String {
            switch self {
            case .appOpen:
                return "App Opened"
            case .exerciseStart:
                return "Exercise Started"
            case .exerciseComplete:
                return "Exercise Completed"
            case .reminderTriggered:
                return "Reminder Sent"
            case .reminderResponded:
                return "Reminder Acknowledged"
            case .inactivityDetected:
                return "Inactivity Detected"
            case .triggerEvaluation:
                return "Trigger Evaluated"
            }
        }
    }
    
    /// Contexts for different times of day.
    enum ActivityDayContext: String, Codable {
        case morning
        case afternoon
        case evening
        case night
    }

    /// Initializes a new ActivityLog entry.
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: ActivityType,
        activityDesc: String,
        duration: Int,
        dayContext: ActivityDayContext,
        triggerType: TriggerType? = nil,
        responded: Bool? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.activityDesc = activityDesc
        self.duration = duration
        self.dayContext = dayContext
        self.triggerType = triggerType
        self.responded = responded
    }
}
