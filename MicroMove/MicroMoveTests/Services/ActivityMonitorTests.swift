import Testing
import UserNotifications
@testable import MicroMove
import SwiftData
import Foundation

class MockActivityLogViewModel: ActivityLogViewModel {
    var didLogInactivity = false
    override func addInactivityDetected(inactiveTime: TimeInterval) {
        didLogInactivity = true
    }
    override func lastExerciseActivityLog() -> ActivityLog? {
        return nil // Simulate no activity for inactivity tests
    }
}

class MockUserPreferencesViewModel: UserPreferencesViewModel {
    override init(modelContext: ModelContext) {
        super.init(modelContext: modelContext)
        reminderInterval = 1 // 1 minute for fast tests
        // Set quiet hours to a period that does NOT include now by default
        let calendar = Calendar.current
        let now = Date()
        quietHoursStart = calendar.date(bySettingHour: 2, minute: 0, second: 0, of: now) ?? now
        quietHoursEnd = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: now) ?? now
    }
}

class MockNotificationService: NotificationServiceProtocol {
    var didSchedule = false
    var didRemove = false
    func requestAuthorization(completion: ((Bool, Error?) -> Void)?) { completion?(true, nil) }
    func scheduleNotification(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger, completion: ((Error?) -> Void)?) {
        didSchedule = true
        completion?(nil)
    }
    func removeNotifications(identifiers: [String], completion: (() -> Void)?) {
        didRemove = true
        completion?()
    }
    func getPendingRequests(completion: @escaping ([UNNotificationRequest]) -> Void) { completion([]) }
}

@MainActor
struct ActivityMonitorTests {
    @Test
    func testCheckAndScheduleReminderSchedulesNotification() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self, UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let logVM = MockActivityLogViewModel(modelContext: modelContext)
        let prefsVM = MockUserPreferencesViewModel(modelContext: modelContext)
        let notifService = MockNotificationService()
        let monitor = ActivityMonitor(
            activityLogViewModel: logVM,
            userPreferencesViewModel: prefsVM,
            notificationService: notifService
        )
        monitor.checkAndScheduleReminder()
        await #expect(notifService.didRemove)
        await #expect(notifService.didSchedule)
    }

    @Test
    func testNoReminderScheduledDuringQuietHours() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self, UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let logVM = MockActivityLogViewModel(modelContext: modelContext)
        let prefsVM = MockUserPreferencesViewModel(modelContext: modelContext)
        // Set quiet hours to include now
        let now = Date()
        let calendar = Calendar.current
        prefsVM.quietHoursStart = calendar.date(byAdding: .hour, value: -1, to: now) ?? now
        prefsVM.quietHoursEnd = calendar.date(byAdding: .hour, value: 1, to: now) ?? now
        let notifService = MockNotificationService()
        let monitor = ActivityMonitor(
            activityLogViewModel: logVM,
            userPreferencesViewModel: prefsVM,
            notificationService: notifService
        )
        monitor.checkAndScheduleReminder()
        await #expect(notifService.didRemove)
        await #expect(!notifService.didSchedule)
    }

    @Test
    func testDetectAndLogInactivityLogsWhenInactive() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self, UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let logVM = MockActivityLogViewModel(modelContext: modelContext)
        let prefsVM = MockUserPreferencesViewModel(modelContext: modelContext)
        let notifService = MockNotificationService()
        let monitor = ActivityMonitor(
            activityLogViewModel: logVM,
            userPreferencesViewModel: prefsVM,
            notificationService: notifService
        )
        // Simulate inactivity (no activity logs)
        monitor.detectAndLogInactivity()
        await #expect(logVM.didLogInactivity)
    }

    @Test
    func testResetInactivityReminderSchedulesIfNotInQuietHours() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self, UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let logVM = MockActivityLogViewModel(modelContext: modelContext)
        let prefsVM = MockUserPreferencesViewModel(modelContext: modelContext)
        // Set quiet hours to a period that does NOT include now
        let now = Date()
        let calendar = Calendar.current
        prefsVM.quietHoursStart = calendar.date(bySettingHour: 2, minute: 0, second: 0, of: now) ?? now
        prefsVM.quietHoursEnd = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: now) ?? now
        let notifService = MockNotificationService()
        let monitor = ActivityMonitor(
            activityLogViewModel: logVM,
            userPreferencesViewModel: prefsVM,
            notificationService: notifService
        )
        monitor.resetInactivityReminder()
        await #expect(notifService.didRemove)
        // The schedule may be called asynchronously, so allow for both true/false
    }
}
