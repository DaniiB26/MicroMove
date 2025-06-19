import Foundation
import SwiftData

@Model
final class Exercise {
    let id: UUID
    var name: String
    var exerciseDesc: String
    var type: ExerciseType
    var bodyPart: BodyPart
    var duration: Int
    let createdAt: Date
    var isCompleted: Bool
    var image: String

    init(id: UUID, name: String, exerciseDesc: String, type: ExerciseType, bodyPart: BodyPart, duration: Int, createdAt: Date, image: String) {
        self.id = id
        self.name = name
        self.exerciseDesc = exerciseDesc
        self.type = type
        self.bodyPart = bodyPart
        self.duration = duration
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.image = image
    }
}
