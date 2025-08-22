import Foundation
import SwiftData

@Model
final class RoutineTrigger {
    let id: UUID
    var triggerType: TriggerType
    var params: [String: String]
    
    init(id: UUID = UUID(), triggerType: TriggerType, params: [String : String] = [:]) {
        self.id = id
        self.triggerType = triggerType
        self.params = params
    }
}

enum TriggerType: String, Codable, CaseIterable {
    case timeRecurring      // every day at HH:mm
    case inactivityMinutes  // no steps/motion for X minutes
    case healthNoStandHour  // no stand hour (HealthKit)
    case deviceIdle         // device idle/motionless
    case homeAutomation     // e.g., TV on > 1hr / Wi‑Fi connected
}

enum TriggerParamKeys {
    static let daysRange = "daysRange"
    static let hour = "hour"
    static let minute = "minute"
    static let minutes = "minutes"
    static let thresholdHours = "thresholdHours"
    static let idleMinutes = "idleMinutes"
    static let event = "event"
    static let ssid = "ssid"
}
