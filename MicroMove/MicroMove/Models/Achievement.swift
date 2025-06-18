import Foundation
import SwiftData

@Model
final class Achievement {
    let id: UUID
    var title: String
    var description: String
    var type: AchievementType
    var requirement: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    enum AchievementType {
        case streak
        case totalExercises
        case totalMinutes
    }

    init(title: String, description: String, type: AchievementType, requirement: Int, isUnlocked: Bool, unlockedAt: Date?) {
        self.title = title
        self.description = description
        self.type = type
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}
