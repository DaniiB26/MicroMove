import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel

    @State private var selectedExerciseIDs: Set<UUID> = []

    private var recommended: [Exercise] {
        if let prefs = userPreferencesViewModel.userPreferences {
            return exercisesViewModel.getRecommendedExercises(from: exercisesViewModel.exercises, prefs: prefs)
        }
        return []
    }
    private var remaining: [Exercise] {
        let recIDs = Set(recommended.map { $0.id })
        return exercisesViewModel.exercises.filter { !recIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            List {
                if !recommended.isEmpty {
                    Section("Recommended") {
                        ForEach(recommended, id: \.id) { ex in
                            exerciseRow(for: ex)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                Section("All Exercises") {
                    ForEach(remaining, id: \.id) { ex in
                        exerciseRow(for: ex)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .navigationTitle("Exercises")
            .onAppear {
                exercisesViewModel.fetchExercises()
                userPreferencesViewModel.fetchUserPreferences()
                selectedExerciseIDs = Set(routine.routineExercise.map { $0.id })
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
                    saveSelection()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFilledButton())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Row with staged toggle
    private func exerciseRow(for ex: Exercise) -> some View {
        let isSelected = selectedExerciseIDs.contains(ex.id)
        return Button {
            if isSelected {
                selectedExerciseIDs.remove(ex.id)
            } else {
                selectedExerciseIDs.insert(ex.id)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: ex.type.iconName)
                    .frame(width: 30, height: 30)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    HStack(spacing: 6) {
                        Text(ex.type.rawValue.capitalized)
                        Text("•")
                        Text(ex.bodyPart.rawValue.capitalized)
                        Text("•")
                        Text("\(ex.duration) min")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .black : .secondary)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // Apply diff on Save
    private func saveSelection() {
        let current = Set(routine.routineExercise.map { $0.id })
        let target  = selectedExerciseIDs

        let toRemove = current.subtracting(target)
        let toAdd    = target.subtracting(current)

        // Remove
        for ex in routine.routineExercise where toRemove.contains(ex.id) {
            routineViewModel.removeExercise(routine, ex)
        }
        // Add
        let all = recommended + remaining
        for ex in all where toAdd.contains(ex.id) {
            routineViewModel.addExercise(routine, ex)
        }

        dismiss()
    }
}