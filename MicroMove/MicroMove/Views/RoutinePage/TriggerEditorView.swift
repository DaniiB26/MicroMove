import SwiftUI

/// View used to create a trigger for a particular exercise.
struct TriggerEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel
    let exercise: Exercise

    @State private var selectedType: TriggerType = .timeRecurring
    @State private var hour: Int = 8
    @State private var minute: Int = 0
    @State private var minutes: Int = 30
    @State private var idleMinutes: Int = 10
    @State private var thresholdHours: Int = 1
    @State private var event: String = ""
    @State private var ssid: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Trigger", selection: $selectedType) {
                    ForEach(TriggerType.allCases, id: \.self) { type in
                        Text(type.label).tag(type)
                    }
                }

                switch selectedType {
                case .timeRecurring:
                    Stepper("Hour: \(hour)", value: $hour, in: 0...23)
                    Stepper("Minute: \(minute)", value: $minute, in: 0...59)
                case .inactivityMinutes:
                    Stepper("Minutes: \(minutes)", value: $minutes, in: 1...240)
                case .healthNoStandHour:
                    Stepper("Hours: \(thresholdHours)", value: $thresholdHours, in: 1...24)
                case .deviceIdle:
                    Stepper("Idle minutes: \(idleMinutes)", value: $idleMinutes, in: 1...240)
                case .homeAutomation:
                    TextField("Event", text: $event)
                    TextField("Wi-Fi SSID", text: $ssid)
                }
            }
            .navigationTitle("New Trigger")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var params: [String:String] = [:]
                        switch selectedType {
                        case .timeRecurring:
                            params[TriggerParamKeys.hour] = String(hour)
                            params[TriggerParamKeys.minute] = String(minute)
                        case .inactivityMinutes:
                            params[TriggerParamKeys.minutes] = String(minutes)
                        case .healthNoStandHour:
                            params[TriggerParamKeys.thresholdHours] = String(thresholdHours)
                        case .deviceIdle:
                            params[TriggerParamKeys.idleMinutes] = String(idleMinutes)
                        case .homeAutomation:
                            if !event.isEmpty { params[TriggerParamKeys.event] = event }
                            if !ssid.isEmpty { params[TriggerParamKeys.ssid] = ssid }
                        }
                        routineViewModel.addTrigger(routine, selectedType, exercise: exercise, params: params)
                        dismiss()
                    }
                }
            }
        }
    }
}