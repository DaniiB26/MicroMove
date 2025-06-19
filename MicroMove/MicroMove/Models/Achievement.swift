import Foundation
import SwiftData

@Model
final class Achievement {
    let id: UUID
    var title: String
    var achievementDesc: String
    var type: AchievementType
    var requirement: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    enum AchievementType {
        case streak
        case totalExercises
        case totalMinutes
    }

    init(id: UUID, title: String, achievementDesc: String, type: AchievementType, requirement: Int, isUnlocked: Bool, unlockedAt: Date?) {
        self.id = id
        self.title = title
        self.achievementDesc = achievementDesc
        self.type = type
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}
