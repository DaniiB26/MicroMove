import Foundation
import SwiftData

@Model
final class Routine {
    let id: UUID
    var name: String
    var notes: String?
    var createdAt: Date
    var isActive: Bool

    var routineTriggers: [RoutineTrigger] = []
    var routineExercise: [Exercise] = []

    init(
        id: UUID = UUID(),
        name: String,
        notes: String? = nil,
        createdAt: Date = .now,
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
    }
}