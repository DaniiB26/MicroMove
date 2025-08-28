import Foundation
import SwiftData

@Model
final class RoutineTrigger {
    let id: UUID
    var triggerType: TriggerType
    var params: [String: String]
    /// The exercise this trigger belongs to.
    /// Each exercise in a routine can own multiple triggers.
    var exercise: Exercise?
    
     init(id: UUID = UUID(), triggerType: TriggerType, params: [String : String] = [:], exercise: Exercise? = nil) {
        self.id = id
        self.triggerType = triggerType
        self.params = params
        self.exercise = exercise
    }
}

/// Convenience helpers for presenting trigger information in the UI.
extension RoutineTrigger {
    /// Returns a human readable summary for the trigger including any parameters.
    var humanReadable: String {
        switch triggerType {
        case .timeRecurring:
            if let hourStr = params[TriggerParamKeys.hour],
            let minuteStr = params[TriggerParamKeys.minute],
            let hour = Int(hourStr),
            let minute = Int(minuteStr) {
                let formatted = String(format: "%02d:%02d", hour, minute)
                return "Every day at \(formatted)"
            }
            return "Every day at --:--"

        case .inactivityMinutes:
            if let mins = params[TriggerParamKeys.minutes] {
                return "Inactive for \(mins) minutes"
            }
            return "Inactive (time unknown)"

        case .healthNoStandHour:
            let hrs = params[TriggerParamKeys.thresholdHours] ?? "1"
            return "No stand hour for \(hrs) hours"

        case .deviceIdle:
            if let mins = params[TriggerParamKeys.idleMinutes] {
                return "Device idle for \(mins) minutes"
            }
            return "Device idle (time unknown)"

        case .homeAutomation:
            if let event = params[TriggerParamKeys.event] {
                return "Home automation: \(event)"
            }
            if let ssid = params[TriggerParamKeys.ssid] {
                return "Wi-Fi connected to \(ssid)"
            }
            return "Home automation trigger"
        }
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

extension TriggerType {
    /// A short human readable label for UI pickers.
    var label: String {
        switch self {
        case .timeRecurring: return "Time"
        case .inactivityMinutes: return "Inactivity"
        case .healthNoStandHour: return "No Stand Hour"
        case .deviceIdle: return "Device Idle"
        case .homeAutomation: return "Home Automation"
        }
    }
}