import Foundation
import SwiftData

/// Represents an achievement unlocked by the user.
@Model
final class Achievement {
    /// Unique identifier for the achievement.
    let id: UUID
    /// Title of the achievement.
    var title: String
    /// Description of the achievement.
    var achievementDesc: String
    /// The type/category of the achievement.
    var type: AchievementType
    /// The requirement value to unlock this achievement.
    var requirement: Int
    /// Whether the achievement is unlocked.
    var isUnlocked: Bool
    /// The date the achievement was unlocked, if applicable.
    var unlockedAt: Date?

    /// Types of achievements available.
    enum AchievementType: String, Codable {
        case streak
        case totalExercises
        case totalMinutes
    }

    /// Initializes a new Achievement.
    init(
        id: UUID = UUID(),
        title: String,
        achievementDesc: String,
        type: AchievementType,
        requirement: Int,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.achievementDesc = achievementDesc
        self.type = type
        self.requirement = requirement
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}