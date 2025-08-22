import SwiftUI

struct RoutineWizard: View {
    @ObservedObject var routineViewModel: RoutineViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var isActive = false
    @FocusState private var nameFieldFocused: Bool

    private var saveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                TextField("Routine name", text: $name)
                    .focused($nameFieldFocused)
                TextField("Notes", text: $notes, axis: .vertical)
            }
            Section {
                Toggle("Active", isOn: $isActive)
            }
        }
        .navigationTitle("New Routine")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let routine = Routine(
                        name: name,
                        notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
                        isActive: isActive
                    )
                    routineViewModel.addRoutine(routine)
                    dismiss()
                }
                .disabled(saveDisabled)
            }
        }
        .onAppear { nameFieldFocused = true }
    }
}