import Foundation
import SwiftData

/// Represents a single exercise in the MicroMove app.
@Model
final class Exercise {
    /// Unique identifier for the exercise.
    let id: UUID
    /// Name of the exercise.
    var name: String
    /// Description of the exercise.
    var exerciseDesc: String
    /// Type of exercise (e.g., strength, cardio).
    var type: ExerciseType
    /// Targeted body part.
    var bodyPart: BodyPart
    /// Difficulty of the exercise
    var difficulty: ExerciseDifficulty
    /// Duration in minutes.
    var duration: Int
    /// Date the exercise was created.
    let createdAt: Date
    /// Whether the exercise has been completed.
    var isCompleted: Bool
    /// Name of the image asset for the exercise.
    var image: String
    /// Instructions for the exercise.
    var instructions: [String] = []
    /// Visual guide for the exercise.
    var visualGuide: [String] = []

    /// Initializes a new Exercise.
    init(
        id: UUID = UUID(),
        name: String,
        exerciseDesc: String,
        type: ExerciseType,
        bodyPart: BodyPart,
        difficulty: ExerciseDifficulty,
        duration: Int,
        createdAt: Date = Date(),
        isCompleted: Bool = false,
        image: String,
        instructions: [String],
        visualGuide: [String]
    ) {
        self.id = id
        self.name = name
        self.exerciseDesc = exerciseDesc
        self.type = type
        self.bodyPart = bodyPart
        self.difficulty = difficulty
        self.duration = duration
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.image = image
        self.instructions = instructions
        self.visualGuide = visualGuide
    }
}
