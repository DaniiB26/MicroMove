import Foundation
import SwiftData

class ExercisesViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchExercises()
    }

    func fetchExercises() {
        do {
            let descriptor = FetchDescriptor<Exercise>()
            exercises = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching exercises: \(error)")
            exercises = []
        }
    }

    func addExercise(_ exercise: Exercise) {
        do {
            try modelContext.insert(exercise)
            fetchExercises()
        } catch {
            print("Error inserting exercise: \(error)")
        }
    }

    func updateExercise(_ exercise: Exercise) {
        do {
            try modelContext.save()
            fetchExercises()
        } catch {
            print("Error updating exercise: \(error)")
        }
    }

    func deleteExercise(_ exercise: Exercise) {
        do {
            modelContext.delete(exercise)
            fetchExercises()
        } catch {
            print("Error deleting exercise: \(error)")
        }
    }
}
