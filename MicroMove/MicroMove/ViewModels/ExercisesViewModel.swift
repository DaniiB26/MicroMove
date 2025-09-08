import Foundation
import SwiftData

/// ViewModel for managing Exercise CRUD operations and state.
@MainActor
class ExercisesViewModel: ObservableObject {
    /// The list of all exercises, published for UI updates.
    @Published var exercises: [Exercise] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?
    /// The currently selected exercise type for filtering.
    @Published var selectedType: ExerciseType? = nil
    /// Whether to sort duration ascending (true) or descending (false).
    @Published var isDurationAscending: Bool = true

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchExercises()
    }

    /// Returns exercises filtered by type and sorted by duration.
    var filteredAndSortedExercises: [Exercise] {
        let filtered = selectedType == nil
            ? exercises
            : exercises.filter { $0.type == selectedType }
        return filtered.sorted {
            isDurationAscending
                ? $0.duration < $1.duration
                : $0.duration > $1.duration
        }
    }

    /// Fetches all exercises from the data store.
    func fetchExercises() {
        do {
            let descriptor = FetchDescriptor<Exercise>()
            exercises = try modelContext.fetch(descriptor)
            print("[ExercisesViewModel] Successfully fetched exercises.")
        } catch {
            errorMessage = "Error fetching exercises: \(error.localizedDescription)"
            exercises = []
        }
    }

    /// Adds a new exercise to the data store and updates the list.
    func addExercise(_ exercise: Exercise) {
        modelContext.insert(exercise)
        exercises.append(exercise)
        print("[ExercisesViewModel] Added exercise: \(exercise.name)")
    }

    /// Saves changes to an existing exercise. Call after modifying an exercise's properties.
    func updateExercise(_ exercise: Exercise) {
        do {
            try modelContext.save()
            print("[ExercisesViewModel] Updated exercise: \(exercise.name)")
            // Optionally update the item in the array if needed
        } catch {
            errorMessage = "Error updating exercise: \(error.localizedDescription)"
        }
    }

    /// Deletes an exercise from the data store and updates the list.
    func deleteExercise(_ exercise: Exercise) {
        do {
            modelContext.delete(exercise)
            try modelContext.save()
            exercises.removeAll { $0.id == exercise.id }
            print("[ExercisesViewModel] Deleted exercise: \(exercise.name)")
        } catch {
            errorMessage = "Error deleting exercise: \(error.localizedDescription)"
        }
    }

    /// Deletes all exercises from the data store.
    func deleteAllExercises(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Exercise>()
        if let exercises = try? modelContext.fetch(fetchDescriptor) {
            for exercise in exercises {
                modelContext.delete(exercise)
            }
            try? modelContext.save()
            print("[ExercisesViewModel] Deleted all exercises.")
        }
    }

    /// Marks an exercise as done (completed) and updates it in the data store.
    func markExerciseAsDone(_ exercise: Exercise) {
        exercise.isCompleted = true
        updateExercise(exercise)
        print("[ExercisesViewModel] Marked exercise as done: \(exercise.name)")
    }

    func getRecommendedExercises(from all: [Exercise], prefs: UserPreferences) -> [Exercise] {
        guard let goal = prefs.fitnessGoal, let level = prefs.fitnessLevel else {
            return []
        }

        let wantedType: ExerciseType = {
            switch goal {
                case .strength: return .strength
                case .cardio, .endurance, .weightLoss: return .cardio
                case .mobility: return .stretch
            }
        } ()

        let list = all.filter { $0.type == wantedType && $0.difficulty.rawValue == level.rawValue }

        return list
    }
}
