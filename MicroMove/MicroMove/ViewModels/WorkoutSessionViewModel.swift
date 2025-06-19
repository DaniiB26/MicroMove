import Foundation
import SwiftData

class WorkoutSessionViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchWorkoutSessions()
    }

    func fetchWorkoutSessions() {
        do {
            let descriptor = FetchDescriptor<WorkoutSession>()
            workoutSessions = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching workout sessions: \(error)")
            workoutSessions = []
        }
    }

    func addWorkoutSession(_ workoutSession: WorkoutSession) {
        do {
            try modelContext.insert(workoutSession)
            fetchWorkoutSessions()
        } catch {
            print("Error inserting workout session: \(error)")
        }
    }

    func updateWorkoutSession(_ workoutSession: WorkoutSession) {
        do {
            try modelContext.save()
            fetchWorkoutSessions()
        } catch {
            print("Error updating workout session: \(error)")
        }
    }

    func deleteWorkoutSession(_ workoutSession: WorkoutSession) {
        do {
            modelContext.delete(workoutSession)
            try modelContext.save()
            fetchWorkoutSessions()
        } catch {
            print("Error deleting workout session: \(error)")
        }
    }
}