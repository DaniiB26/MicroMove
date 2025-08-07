import SwiftData
import Foundation

@Model
final class ExerciseDTO {
    let id: UUID
    let baseExercise: Exercise
    var startedAt: Date?
    var completedAt: Date?

    init(baseExercise: Exercise, startedAt: Date? = nil, completedAt: Date? = nil) {
        self.id = UUID()
        self.baseExercise = baseExercise
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}