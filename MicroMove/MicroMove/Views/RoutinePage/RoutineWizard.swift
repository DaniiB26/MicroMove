import SwiftUI
import SwiftData

struct RoutineWizard: View {
    @ObservedObject var routineViewModel: RoutineViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var isActive = false
    @FocusState private var nameFieldFocused: Bool

    @State private var recommendedExercises: [Exercise] = []
    @State private var selectedExerciseIDs: Set<UUID> = []
    @State private var searchText: String = ""

    private var saveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var filteredExercises: [Exercise] {
        guard !searchText.isEmpty else { return recommendedExercises }
        return recommendedExercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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

            if !recommendedExercises.isEmpty {
                Section("Recommended Exercises") {
                    ForEach(filteredExercises, id: \.id) { ex in
                        Button(action: { toggleSelection(ex) }) {
                            HStack {
                                Text(ex.name)
                                Spacer()
                                if selectedExerciseIDs.contains(ex.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
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
                    let selected = recommendedExercises.filter { selectedExerciseIDs.contains($0.id) }
                    selected.forEach { routineViewModel.addExercise(routine, $0) }
                    dismiss()
                }
                .disabled(saveDisabled)
            }
        }
        .onAppear {
            nameFieldFocused = true
            loadRecommendedExercises()
        }
        .searchable(text: $searchText)
    }

    private func loadRecommendedExercises() {
        do {
            let descriptor = FetchDescriptor<Exercise>()
            let all = try modelContext.fetch(descriptor)
            if let prefs = try modelContext.fetch(FetchDescriptor<UserPreferences>()).first {
                let vm = ExercisesViewModel(modelContext: modelContext)
                recommendedExercises = vm.getRecommendedExercises(from: all, prefs: prefs)
            } else {
                recommendedExercises = []
            }
        } catch {
            recommendedExercises = []
        }
    }

    private func toggleSelection(_ exercise: Exercise) {
        if selectedExerciseIDs.contains(exercise.id) {
            selectedExerciseIDs.remove(exercise.id)
        } else {
            selectedExerciseIDs.insert(exercise.id)
        }
    }
}