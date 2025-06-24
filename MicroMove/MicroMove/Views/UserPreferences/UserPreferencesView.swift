import SwiftUI

struct UserPreferencesView: View {
    @ObservedObject var viewModel: UserPreferencesViewModel
    @State private var isEditing = false

    var body: some View {
        Form{
            Section(header: Text("Reminders")) {
                if isEditing {
                    Stepper("Reminder Interval: \(viewModel.reminderInterval) min", value: $viewModel.reminderInterval)
                    DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                }
                else {
                    HStack {
                        Text("Reminder Interval")
                        Spacer()
                        Text("\(viewModel.reminderInterval) min")
                    }
                    HStack {
                        Text("Reminder Time")
                        Spacer()
                        Text(viewModel.reminderTime, style: .time)
                    }
                }
            }
            Section(header: Text("Quiet Hours")) {
                if isEditing {
                    DatePicker("Start", selection: $viewModel.quietHoursStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $viewModel.quietHoursEnd, displayedComponents: .hourAndMinute)
                }
                else {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text(viewModel.quietHoursStart, style: .time)
                    }
                    HStack {
                        Text("End")
                        Spacer()
                        Text(viewModel.quietHoursEnd, style: .time)
                    }
                }
            }
            if isEditing {
                Button("Save") {
                    viewModel.savePreferences()
                    isEditing = false
                }
            }
        }
        .navigationTitle("Preferences")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                }
                .accessibilityLabel(isEditing ? "Done Editing" : "Edit Preferences")
            }
        }
    }
}