import Foundation
import SwiftData

@Model
final class WorkoutSession {
    let id: UUID
    var date: Date
    var duration: Int
    var exercises: [Exercise]
    var startedAt: Date
    var completedAt: Date

    init(id: UUID, date: Date, duration: Int, exercises: [Exercise], startedAt: Date, completedAt: Date) {
        self.id = id
        self.date = date
        self.duration = duration
        self.exercises = exercises
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}
