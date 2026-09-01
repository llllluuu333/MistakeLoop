import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var reminderTime = Date()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("复习提醒") {
                Toggle("每日复习提醒", isOn: $reminderEnabled)
                if reminderEnabled {
                    DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            Section {
                Button("发送一条测试提醒") {
                    Task {
                        _ = await ReminderService.requestAuthorization()
                        ReminderService.sendTestReminder()
                    }
                }
            } footer: {
                Text("开启后每天会在设定时间提醒你完成复习队列。")
            }
            Section {
                Text("版本 2.0")
                    .foregroundStyle(Theme.grayText)
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
            }
        }
        .onAppear {
            let calendar = Calendar.current
            reminderTime = calendar.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: .now) ?? .now
        }
        .onChange(of: reminderTime) {
            applyReminder()
        }
        .onChange(of: reminderEnabled) {
            applyReminder()
        }
    }

    private func applyReminder() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        if reminderEnabled {
            reminderHour = components.hour ?? 20
            reminderMinute = components.minute ?? 0
            Task {
                _ = await ReminderService.requestAuthorization()
                ReminderService.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            }
        } else {
            ReminderService.cancelDailyReminder()
        }
    }
}
