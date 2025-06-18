import Foundation
import SwiftData

@Model
final class UserPreferences {
    let id: UUID
    var reminderInterval: Int
    var reminderTime: Date
    var quietHoursStart: Date
    var quietHoursEnd: Date

    init(reminderInterval: Int, reminderTime: Date, quietHoursStart: Date, quietHoursEnd: Date) {
        self.reminderInterval = reminderInterval
        self.reminderTime = reminderTime
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
    }
}
