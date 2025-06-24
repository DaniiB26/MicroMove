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
    /// Duration of the activity in minutes.
    var duration: Int
    /// Context of the day when the activity occurred.
    var dayContext: ActivityDayContext

    /// Types of activities that can be logged.
    enum ActivityType: String, Codable {
        case appOpen
        case exerciseStart
        case exerciseComplete
        case reminderTriggered
        case reminderResponded
        case inactivityDetected
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
        duration: Int,
        dayContext: ActivityDayContext
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.duration = duration
        self.dayContext = dayContext
    }
}