@Model
final class Exercise {
    var id: UUID
    var name: String
    var description: String
    var type: String
    var bodyPart: String
    var duration: Int
    var createdAt: Date
    var image: String

    init(name: String, description: String, type: String, bodyPart: String, duration: Int, createdAt: Date, image: String) {
        self.name = name
        self.description = description
        self.type = type
        self.bodyPart = bodyPart
        self.duration = duration
        self.createdAt = createdAt
        self.image = image
    }
}