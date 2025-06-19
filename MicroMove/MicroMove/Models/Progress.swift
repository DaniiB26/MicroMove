import Foundation
import SwiftData

@Model
final class Progress {
    let id: UUID
    var exercisesCompleted: Int
    var totalMinutes: Int
    var currentStreak: Int
    var longestStreak: Int
    var workoutSessions: [WorkoutSession]
    var lastUpdatedAt: Date
    var achievements: [Achievement]

    init(id: UUID, exercisesCompleted: Int, totalMinutes: Int, currentStreak: Int, longestStreak: Int, workoutSessions: [WorkoutSession], lastUpdatedAt: Date, achievements: [Achievement]) {
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
