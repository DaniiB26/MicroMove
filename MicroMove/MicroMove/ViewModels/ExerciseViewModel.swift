import Foundation
import SwiftData

/// ViewModel for managing Exercise CRUD operations and state.
@MainActor
class ExercisesViewModel: ObservableObject {
    /// The list of all exercises, published for UI updates.
    @Published var exercises: [Exercise] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    @Published var selectedType: ExerciseType? = nil

    @Published var isDurationAscending: Bool = true

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchExercises()
    }

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
        } catch {
            errorMessage = "Error fetching exercises: \(error.localizedDescription)"
            exercises = []
        }
    }

    /// Adds a new exercise to the data store and updates the list.
    func addExercise(_ exercise: Exercise) {
        modelContext.insert(exercise)
        exercises.append(exercise)
    }

    /// Saves changes to an existing exercise. Call after modifying an exercise's properties.
    func updateExercise(_ exercise: Exercise) {
        do {
            try modelContext.save()
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
        } catch {
            errorMessage = "Error deleting exercise: \(error.localizedDescription)"
        }
    }
}
