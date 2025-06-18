import Foundation
import SwiftData

@Model
final class Exercise {
    let id: UUID
    var name: String
    var description: String
    var type: ExerciseType
    var bodyPart: BodyPart
    var duration: Int
    let createdAt: Date
    var image: String

    init(name: String, description: String, type: ExerciseType, bodyPart: BodyPart, duration: Int, createdAt: Date, image: String) {
        self.name = name
        self.description = description
        self.type = type
        self.bodyPart = bodyPart
        self.duration = duration
        self.createdAt = createdAt
        self.image = image
    }
}