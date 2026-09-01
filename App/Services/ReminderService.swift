import Foundation
import UserNotifications

enum ReminderService {
    static let reminderIdentifier = "dailyReviewReminder"
    static let testIdentifier = "testReminder"

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "该复习啦"
        content.body = "今天的复习队列在等你，花几分钟就搞定。"
        content.sound = .default

        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    static func sendTestReminder() {
        let content = UNMutableNotificationContent()
        content.title = "该复习啦"
        content.body = "这是一条测试提醒，5 秒后到达。"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: testIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
