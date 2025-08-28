import SwiftUI

struct RoutineWizard: View {
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @Environment(\.dismiss) private var dismiss

    // Inputs
    @State private var name = ""
    @State private var notes = ""
    @State private var isActive = false
    @FocusState private var nameFocused: Bool

    // Selection
    @State private var selectedExerciseIDs: Set<UUID> = []

    private var recommended: [Exercise] {
        guard let prefs = userPreferencesViewModel.userPreferences else { return [] }
        return exercisesViewModel.getRecommendedExercises(from: exercisesViewModel.exercises, prefs: prefs)
    }
    private var others: [Exercise] {
        let recIDs = Set(recommended.map { $0.id })
        return exercisesViewModel.exercises.filter { !recIDs.contains($0.id) }
    }

    private var saveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Create Routine").font(.largeTitle.bold())
                            Text("Pick a name, choose exercises, and set it active.")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .font(.title2).foregroundColor(.accentColor)
                    }
                    .padding(.horizontal, 16)

                    // Basics
                    Card {
                        Text("Basics").font(.headline)

                        TextField("Routine name", text: $name)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .focused($nameFocused)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Toggle("Active", isOn: $isActive).tint(.black)
                    }

                    // Recommended
                    Card {
                        HStack {
                            Text("Recommended").font(.headline)
                            Spacer()
                            if !recommended.isEmpty {
                                Button("Add all") {
                                    selectedExerciseIDs.formUnion(recommended.map { $0.id })
                                }
                                .font(.footnote.weight(.semibold))
                            }
                        }

                        if recommended.isEmpty {
                            Text("No recommendations yet.")
                                .font(.subheadline).foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(recommended, id: \.id) { ex in
                                    ExerciseRowCard(
                                        exercise: ex,
                                        isSelected: selectedExerciseIDs.contains(ex.id),
                                        onToggle: { toggleSelection(ex) }
                                    )
                                }
                            }
                        }
                    }

                    // All others
                    Card {
                        HStack {
                            Text("All Exercises").font(.headline)
                            Spacer()
                            if !others.isEmpty {
                                Button("Add all") {
                                    selectedExerciseIDs.formUnion(others.map { $0.id })
                                }
                                .font(.footnote.weight(.semibold))
                            }
                        }

                        if others.isEmpty {
                            Text("No other exercises.")
                                .font(.subheadline).foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(others, id: \.id) { ex in
                                    ExerciseRowCard(
                                        exercise: ex,
                                        isSelected: selectedExerciseIDs.contains(ex.id),
                                        onToggle: { toggleSelection(ex) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("New Routine")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button(role: .cancel) { dismiss() } label: {
                    Text("Discard").frame(maxWidth: .infinity)
                }

                Button { saveRoutine() } label: {
                    Text(selectedExerciseIDs.isEmpty ? "Save" : "Save (\(selectedExerciseIDs.count))")
                        .frame(maxWidth: .infinity)
                }
                .disabled(saveDisabled)
                .opacity(saveDisabled ? 0.6 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .onAppear {
            exercisesViewModel.fetchExercises()
            userPreferencesViewModel.fetchUserPreferences()
            nameFocused = true
        }
    }

    //Actions
    private func toggleSelection(_ exercise: Exercise) {
        if selectedExerciseIDs.contains(exercise.id) {
            selectedExerciseIDs.remove(exercise.id)
        } else {
            selectedExerciseIDs.insert(exercise.id)
        }
    }

    private func saveRoutine() {
        let routine = Routine(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
            isActive: isActive
        )
        routineViewModel.addRoutine(routine)

        let chosenIDs = selectedExerciseIDs
        for e in exercisesViewModel.exercises where chosenIDs.contains(e.id) {
            routineViewModel.addExercise(routine, e)
        }
        dismiss()
    }
}