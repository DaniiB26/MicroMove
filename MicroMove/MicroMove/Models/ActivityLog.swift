import Foundation
import SwiftData

@Model
final class ActivityLog {
    let id: UUID
    var timestamp: Date
    var type: ActivityType
    var duration: Int
    var dayContext: ActivityDayContext

    enum ActivityType: String {
        case screenUnlock
        case appOpen
        case exerciseStart
        case exerciseComplete
        case reminderTriggered
    }
    
    enum ActivityContext: String {
        case morning
        case afternoon
        case evening
        case night
    }

    init(timestamp: Date, type: ActivityType, duration: Int, dayContext: ActivityDayContext) {
        self.timestamp = timestamp
        self.type = type
        self.duration = duration
        self.dayContext = dayContext
    }
}
