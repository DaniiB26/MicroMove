import Foundation
import SwiftData

/// Represents a workout session containing multiple exercises.
@Model
final class WorkoutSession {
    /// Unique identifier for the session.
    let id: UUID
    /// Date of the workout session.
    var date: Date
    /// Total duration of the session in minutes.
    var duration: Int
    /// List of exercises performed in this session.
    var exercises: [Exercise]
    /// Timestamp when the session started.
    var startedAt: Date?
    /// Timestamp when the session was completed.
    var completedAt: Date?

    /// Initializes a new WorkoutSession.
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: Int = 0,
        exercises: [Exercise] = [],
        startedAt: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.exercises = exercises
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}