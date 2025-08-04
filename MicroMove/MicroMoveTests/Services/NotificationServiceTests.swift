import Testing
@testable import MicroMove
import UserNotifications

// Mock for UNUserNotificationCenter
class MockUserNotificationCenter: UserNotificationCenterProtocol {
    var didRequestAuthorization = false
    var didScheduleNotification = false
    var didRemoveNotifications = false
    var didRemoveDeliveredNotifications = false
    var pendingRequests: [UNNotificationRequest] = []

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        didRequestAuthorization = true
        completionHandler(true, nil)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        didScheduleNotification = true
        pendingRequests.append(request)
        completionHandler?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        didRemoveNotifications = true
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        didRemoveDeliveredNotifications = true
    }

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(pendingRequests)
    }
}

// Test NotificationService
@MainActor
struct NotificationServiceTests {
    @Test
    func testRequestAuthorizationCallsCenter() async throws {
        let mockCenter = MockUserNotificationCenter()
        let service = NotificationService(center: mockCenter)
        var didCall = false
        service.requestAuthorization { granted, error in
            didCall = true
        }
        await #expect(mockCenter.didRequestAuthorization)
        await #expect(didCall)
    }

    @Test
    func testScheduleNotificationCallsCenter() async throws {
        let mockCenter = MockUserNotificationCenter()
        let service = NotificationService(center: mockCenter)
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        var didCall = false
        service.scheduleNotification(identifier: "test", content: content, trigger: trigger) { error in
            didCall = true
        }
        await #expect(mockCenter.didScheduleNotification)
        await #expect(didCall)
        await #expect(mockCenter.pendingRequests.contains { $0.identifier == "test" })
    }

    @Test
    func testRemoveNotificationsCallsCenter() async throws {
        let mockCenter = MockUserNotificationCenter()
        let service = NotificationService(center: mockCenter)
        // Add a request to pendingRequests
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "removeMe", content: content, trigger: trigger)
        mockCenter.pendingRequests.append(request)
        var didCall = false
        service.removeNotifications(identifiers: ["removeMe"]) {
            didCall = true
        }
        await #expect(mockCenter.didRemoveNotifications)
        await #expect(mockCenter.didRemoveDeliveredNotifications)
        await #expect(didCall)
        await #expect(!mockCenter.pendingRequests.contains { $0.identifier == "removeMe" })
    }

    @Test
    func testGetPendingRequestsReturnsRequests() async throws {
        let mockCenter = MockUserNotificationCenter()
        let service = NotificationService(center: mockCenter)
        // Add a request to pendingRequests
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "pending", content: content, trigger: trigger)
        mockCenter.pendingRequests.append(request)
        var received: [UNNotificationRequest] = []
        service.getPendingRequests { requests in
            received = requests
        }
        await #expect(received.contains { $0.identifier == "pending" })
    }
}