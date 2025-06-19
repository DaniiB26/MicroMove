import Foundation
import SwiftData

/// Tracks the user's overall progress in the app.
@Model
final class Progress {
    /// Unique identifier for the progress record.
    let id: UUID
    /// Total number of exercises completed.
    var exercisesCompleted: Int
    /// Total minutes spent exercising.
    var totalMinutes: Int
    /// Current streak of consecutive days with activity.
    var currentStreak: Int
    /// Longest streak achieved.
    var longestStreak: Int
    /// List of workout sessions.
    var workoutSessions: [WorkoutSession]
    /// Last time the progress was updated.
    var lastUpdatedAt: Date
    /// List of achievements earned.
    var achievements: [Achievement]

    /// Initializes a new Progress record.
    init(
        id: UUID = UUID(),
        exercisesCompleted: Int = 0,
        totalMinutes: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        workoutSessions: [WorkoutSession] = [],
        lastUpdatedAt: Date = Date(),
        achievements: [Achievement] = []
    ) {
        self.id = id
        self.exercisesCompleted = exercisesCompleted
        self.totalMinutes = totalMinutes
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.workoutSessions = workoutSessions
        self.lastUpdatedAt = lastUpdatedAt
        self.achievements = achievements
    }
}