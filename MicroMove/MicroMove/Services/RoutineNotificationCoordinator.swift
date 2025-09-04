import Foundation
import UserNotifications
import HealthKit

@MainActor
final class RoutineNotificationCoordinator {
    private let activityLogViewModel: ActivityLogViewModel
    private let notificationService: NotificationServiceProtocol
    private var routines: [Routine]
    private var exercises: [Exercise]
    private let healthStore = HKHealthStore()
    private var healthKitAuthorized = false

    init(activityLogViewModel: ActivityLogViewModel,
         notificationService: NotificationServiceProtocol = NotificationService(),
         routines: [Routine],
         exercises: [Exercise]) {
        self.activityLogViewModel = activityLogViewModel
        self.notificationService = notificationService
        self.routines = routines
        self.exercises = exercises
    }

    func updateData(routines: [Routine], exercises: [Exercise]) {
        self.routines = routines
        self.exercises = exercises
    }

    func scheduleAllTriggers() {
        // Request HealthKit permission only if stand-hour triggers exist
        let hasStandTriggers = routines.contains { $0.routineTriggers.contains { $0.triggerType == .healthNoStandHour } }
        if hasStandTriggers && !healthKitAuthorized {
            requestHealthKitPermissions()
        }
        // Clean up any pending notifications for triggers that no longer exist
        reconcileScheduledNotifications()
        // Schedule/evaluate current active routine triggers
        for routine in routines where routine.isActive {
            for trigger in routine.routineTriggers {
                switch trigger.triggerType {
                case .timeRecurring:
                    scheduleTimeTrigger(trigger, routine: routine)
                case .inactivityMinutes:
                    evaluateScreenTimeInactivity(trigger)
                case .healthNoStandHour:
                    evaluateStandHours(trigger)
                default:
                    break
                }
            }
        }
    }

    // Logging occurs on delivery via AppDelegate; no prelogging here.
    
    /// Requests HealthKit permissions for stand time data.
    private func requestHealthKitPermissions() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let standTimeType = HKObjectType.quantityType(forIdentifier: .appleStandTime)!
        let typesToRead = Set([standTimeType])
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.healthKitAuthorized = true
                print("[RoutineNotificationCoordinator] HealthKit permission granted")
            } else if let error = error {
                self.healthKitAuthorized = false
                print("[RoutineNotificationCoordinator] HealthKit permission error: \(error.localizedDescription)")
            }
        }
    }

    /// Schedules a daily notification for a `.timeRecurring` trigger.
    private func scheduleTimeTrigger(_ trigger: RoutineTrigger, routine: Routine) {
        guard
            let hourStr = trigger.params[TriggerParamKeys.hour],
            let minuteStr = trigger.params[TriggerParamKeys.minute],
            let hour = Int(hourStr),
            let minute = Int(minuteStr)
        else {return}

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = notificationContent(for: routine, exercise: trigger.exercise)
        // Group by trigger so notifications stack in Notification Center
        content.threadIdentifier = "\(NotificationIdentifiers.triggerThreadPrefix)\(trigger.id.uuidString)"
        // Attach metadata for identification on delivery
        content.userInfo[NotificationUserInfoKeys.triggerID] = trigger.id.uuidString
        content.userInfo[NotificationUserInfoKeys.triggerType] = trigger.triggerType.rawValue
        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        notificationService.scheduleNotification(identifier: trigger.id.uuidString, content: content, trigger: calendarTrigger, completion: nil)
    }

    /// Generates notification content for a routine/exercise pair.
    private func notificationContent(for routine: Routine?, exercise: Exercise?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = routine?.name ?? "Time to Move"
        if let exercise = exercise {
            content.body = "Let's do \(exercise.name)!"
        } else {
            content.body = "Let's get active!"
        }
        content.sound = .default
        return content
    }

    /// Returns the routine that owns a given trigger.
    private func routineForTrigger(_ trigger: RoutineTrigger) -> Routine? {
        routines.first { routine in
            routine.routineTriggers.contains { $0.id == trigger.id }
        }
    }

    /// Finds a trigger by identifier across all routines.
    private func findTrigger(by identifier: String) -> RoutineTrigger? {
        for routine in routines {
            if let trig = routine.routineTriggers.first(where: { $0.id.uuidString == identifier }) {
                return trig
            }
        }
        return nil
    }

    /// Public resolver: maps a notification identifier to its RoutineTrigger if present.
    func trigger(forNotificationIdentifier identifier: String) -> RoutineTrigger? {
        return findTrigger(by: identifier)
    }

    /// Finds a trigger by its UUID string regardless of notification identifier usage.
    func triggerByIDString(_ id: String) -> RoutineTrigger? {
        return findTrigger(by: id)
    }

    /// Evaluates `.inactivityMinutes` triggers based on last app open.
    func evaluateScreenTimeInactivity(_ trigger: RoutineTrigger) {
        guard let thresholdStr = trigger.params[TriggerParamKeys.minutes],
              let minutes = Double(thresholdStr) else { return }

        let lastOpen = activityLogViewModel.activityLogs
            .filter { $0.type == .appOpen }
            .sorted { $0.timestamp > $1.timestamp }
            .first?.timestamp

        let elapsed = lastOpen.map { Date().timeIntervalSince($0) } ?? .greatestFiniteMagnitude
        if elapsed > minutes * 60 {
            let content = notificationContent(for: routineForTrigger(trigger), exercise: trigger.exercise)
            content.threadIdentifier = "\(NotificationIdentifiers.triggerThreadPrefix)\(trigger.id.uuidString)"
            // Attach metadata for identification on delivery
            content.userInfo[NotificationUserInfoKeys.triggerID] = trigger.id.uuidString
            content.userInfo[NotificationUserInfoKeys.triggerType] = trigger.triggerType.rawValue
            let trig = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            notificationService.scheduleNotification(identifier: trigger.id.uuidString, content: content, trigger: trig, completion: nil)
        }
    }

    /// Evaluates `.healthNoStandHour` triggers using HealthKit stand data.
    func evaluateStandHours(_ trigger: RoutineTrigger) {
        guard healthKitAuthorized,
              let thresholdStr = trigger.params[TriggerParamKeys.thresholdHours],
              let hours = Double(thresholdStr),
              HKHealthStore.isHealthDataAvailable(),
              let standType = HKObjectType.quantityType(forIdentifier: .appleStandTime) else { return }

        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .hour, value: Int(-hours), to: endDate) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let query = HKStatisticsQuery(quantityType: standType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            let stand = stats?.sumQuantity()?.doubleValue(for: HKUnit.hour()) ?? 0
            if stand < 1 { // No stand hour recorded
                let content = self.notificationContent(for: self.routineForTrigger(trigger), exercise: trigger.exercise)
                content.threadIdentifier = "\(NotificationIdentifiers.triggerThreadPrefix)\(trigger.id.uuidString)"
                // Attach metadata for identification on delivery
                content.userInfo[NotificationUserInfoKeys.triggerID] = trigger.id.uuidString
                content.userInfo[NotificationUserInfoKeys.triggerType] = trigger.triggerType.rawValue
                let trig = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                self.notificationService.scheduleNotification(identifier: trigger.id.uuidString, content: content, trigger: trig, completion: nil)
            }
        }
        healthStore.execute(query)
    }

    /// Removes any pending notifications that do not correspond to current active triggers.
    func reconcileScheduledNotifications() {
        let activeTriggerIDs: Set<String> = Set(
            routines
                .filter { $0.isActive }
                .flatMap { $0.routineTriggers }
                .map { $0.id.uuidString }
        )
        notificationService.getPendingRequests { requests in
            let stale = requests
                .map { $0.identifier }
                .filter { !activeTriggerIDs.contains($0) && $0 != NotificationIdentifiers.movementReminder }
            if !stale.isEmpty {
                // Remove only pending requests so delivered notifications remain for stats
                self.notificationService.removePending(identifiers: stale, completion: nil)
            }
        }
    }
}
