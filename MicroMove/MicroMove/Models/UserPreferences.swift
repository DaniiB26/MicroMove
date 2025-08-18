import Foundation
import SwiftData

/// Stores user-configurable preferences for reminders and quiet hours.
@Model
final class UserPreferences {
    /// Unique identifier for the preferences record.
    let id: UUID
    /// User name for better UI
    var userName: String?
    // Fitness Level
    var fitnessLevel : FitnessLevel?
    // Fitness Goal
    var fitnessGoal : FitnessGoal?
    /// Interval between reminders, in minutes.
    var reminderInterval: Int
    /// Default time for reminders.
    var reminderTime: Date
    /// Start of quiet hours.
    var quietHoursStart: Date
    /// End of quiet hours.
    var quietHoursEnd: Date

    /// Initializes a new UserPreferences record.
    init(
        id: UUID = UUID(),
        userName: String? = "",
        fitnessLevel: FitnessLevel,
        fitnessGoal: FitnessGoal,
        reminderInterval: Int = 60,
        reminderTime: Date = Date(),
        quietHoursStart: Date = Date(),
        quietHoursEnd: Date = Date()
    ) {
        self.id = id
        self.userName = userName
        self.fitnessLevel = fitnessLevel
        self.fitnessGoal = fitnessGoal
        self.reminderInterval = reminderInterval
        self.reminderTime = reminderTime
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
    }
}
