import SwiftUI

struct TriggerEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel
    let exercise: Exercise

    // State
    @State private var selectedType: TriggerType = .timeRecurring
    @State private var timeOfDay: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var minutes: Int = 30
    @State private var idleMinutes: Int = 10
    @State private var thresholdHours: Int = 1
    @State private var event: String = ""
    @State private var ssid: String  = ""

    private var canSave: Bool {
        switch selectedType {
        case .timeRecurring:       return true
        case .inactivityMinutes:   return minutes > 0
        case .healthNoStandHour:   return thresholdHours > 0
        case .deviceIdle:          return idleMinutes > 0
        case .homeAutomation:
            return !event.trimmingCharacters(in: .whitespaces).isEmpty ||
                   !ssid.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("New Trigger")
                                .font(.largeTitle.bold())
                            Text(exercise.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    // Trigger Type (Dropdown)
                    Card {
                        Text("Trigger Type")
                            .font(.headline)

                        HStack {
                            Text(selectedType.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)

                            Spacer()

                            Menu {
                                ForEach(TriggerType.allCases, id: \.self) { type in
                                    Button {
                                        selectedType = type
                                    } label: {
                                        HStack {
                                            Text(type.label)
                                            if type == selectedType {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Change")
                                    Image(systemName: "chevron.down")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }

                    // Parameters
                    Card {
                        Text("Parameters")
                            .font(.headline)

                        switch selectedType {
                        case .timeRecurring:
                            HStack {
                                Text("Time")
                                Spacer()
                                DatePicker("", selection: $timeOfDay, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }

                        case .inactivityMinutes:
                            Stepper("Minutes: \(minutes)", value: $minutes, in: 1...240)

                        case .healthNoStandHour:
                            Stepper("Hours: \(thresholdHours)", value: $thresholdHours, in: 1...24)

                        case .deviceIdle:
                            Stepper("Idle minutes: \(idleMinutes)", value: $idleMinutes, in: 1...240)

                        case .homeAutomation:
                            VStack(spacing: 10) {
                                TextField("Event (optional)", text: $event)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                TextField("Wi-Fi SSID (optional)", text: $ssid)
                                    .textInputAutocapitalization(.never)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.bottom, 88) // room for bottom bar
                }
                .padding(.vertical, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondarySoftButton())

                Button {
                    save()
                } label: {
                    Text("Save Trigger")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFilledButton())
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        var params: [String: String] = [:]

        switch selectedType {
        case .timeRecurring:
            let c = Calendar.current.dateComponents([.hour, .minute], from: timeOfDay)
            params[TriggerParamKeys.hour]   = String(c.hour ?? 8)
            params[TriggerParamKeys.minute] = String(c.minute ?? 0)

        case .inactivityMinutes:
            params[TriggerParamKeys.minutes] = String(minutes)

        case .healthNoStandHour:
            params[TriggerParamKeys.thresholdHours] = String(thresholdHours)

        case .deviceIdle:
            params[TriggerParamKeys.idleMinutes] = String(idleMinutes)

        case .homeAutomation:
            if !event.isEmpty { params[TriggerParamKeys.event] = event }
            if !ssid.isEmpty  { params[TriggerParamKeys.ssid]  = ssid  }
        }

        routineViewModel.addTrigger(routine, selectedType, exercise: exercise, params: params)
        dismiss()
    }
}