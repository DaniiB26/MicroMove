import Foundation
import UserNotifications

@MainActor
final class CheckInScheduler {
    private let notificationService: NotificationServiceProtocol
    private let identifier = NotificationIdentifiers.weeklyCheckIn
    private let hour: Int

    init(notificationService: NotificationServiceProtocol = NotificationService(), checkInHour: Int = 10) {
        self.notificationService = notificationService
        self.hour = checkInHour
        requestAuthorization()
    }

    private func requestAuthorization() {
        notificationService.requestAuthorization { granted, error in
            if let error = error {
                print("[CheckInScheduler] Authorization error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNextCheckIn(from date: Date = Date()) {
        let nextDate = Self.nextMonday(from: date, hour: hour)
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Weekly Check-In"
        content.body = "How did your training go last week?"
        content.sound = .default

        notificationService.removePending(identifiers: [identifier]) { [weak self] in
            guard let self = self else { return }
            self.notificationService.scheduleNotification(identifier: self.identifier, content: content, trigger: trigger) { error in
                if let error = error {
                    print("[CheckInScheduler] Failed to schedule check-in: \(error.localizedDescription)")
                } else {
                    print("[CheckInScheduler] Scheduled check-in for \(nextDate)")
                }
            }
        }
    }

    func handleCheckInCompleted(at date: Date = Date()) {
        scheduleNextCheckIn(from: date)
    }

    static func nextMonday(from date: Date = Date(), hour: Int = 10) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        var daysToAdd = (2 - weekday + 7) % 7
        let currentHour = calendar.component(.hour, from: date)
        if daysToAdd == 0 && currentHour >= hour {
            daysToAdd = 7
        }
        let next = calendar.date(byAdding: .day, value: daysToAdd, to: date) ?? date
        var comps = calendar.dateComponents([.year, .month, .day], from: next)
        comps.hour = hour
        comps.minute = 0
        return calendar.date(from: comps) ?? next
    }
}
