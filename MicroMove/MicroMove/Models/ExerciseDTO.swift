import SwiftData
import Foundation

@Model
final class ExerciseDTO {
    let id: UUID
    let baseExercise: Exercise
    var startedAt: Date?
    var completedAt: Date?
    var duration: Int
    var reps: Int?
    var weight: Int?
    var endedEarly: Bool

    init(baseExercise: Exercise, startedAt: Date? = nil, completedAt: Date? = nil, duration: Int = 0, reps: Int? = nil, weight: Int? = nil, endedEarly: Bool = false) {
        self.id = UUID()
        self.baseExercise = baseExercise
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.reps = reps
        self.weight = weight
        self.endedEarly = endedEarly
    }
}