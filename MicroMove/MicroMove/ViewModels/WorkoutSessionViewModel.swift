import Foundation
import SwiftData

/// ViewModel for managing WorkoutSession CRUD operations and state.
@MainActor
class WorkoutSessionViewModel: ObservableObject {
    /// The list of all workout sessions, published for UI updates.
    @Published var workoutSessions: [WorkoutSession] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchWorkoutSessions()
    }

    /// Fetches all workout sessions from the data store.
    func fetchWorkoutSessions() {
        do {
            let descriptor = FetchDescriptor<WorkoutSession>()
            workoutSessions = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error fetching workout sessions: \(error.localizedDescription)"
            workoutSessions = []
        }
    }

    /// Adds a new workout session to the data store and updates the list.
    func addWorkoutSession(_ session: WorkoutSession) {
        modelContext.insert(session)
        workoutSessions.append(session)
    }

    /// Saves changes to an existing workout session. Call after modifying a session's properties.
    func updateWorkoutSession(_ session: WorkoutSession) {
        do {
            try modelContext.save()
            // Optionally update the item in the array if needed
        } catch {
            errorMessage = "Error updating workout session: \(error.localizedDescription)"
        }
    }

    /// Deletes a workout session from the data store and updates the list.
    func deleteWorkoutSession(_ session: WorkoutSession) {
        do {
            modelContext.delete(session)
            try modelContext.save()
            workoutSessions.removeAll { $0.id == session.id }
        } catch {
            errorMessage = "Error deleting workout session: \(error.localizedDescription)"
        }
    }

    func addExerciseToSession(exercise: Exercise) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todaySession = workoutSessions.first(where: { calendar.isDate($0.date, inSameDayAs: today) })

        let now = Date()
        if let session = todaySession {
            session.exercises.append(exercise)
            session.duration += exercise.duration
            if session.startedAt == nil {
                session.startedAt = now
            }
            session.completedAt = now + TimeInterval(exercise.duration * 60)
            updateWorkoutSession(session)
            do {
                try modelContext.save()
                print("[WorkoutSession] Updated today's session:")
                print("  Date: \(session.date)")
                print("  Exercises: \(session.exercises.map { $0.name }) (\(session.exercises.count) total)")
                print("  Duration: \(session.duration) min")
                print("  StartedAt: \(String(describing: session.startedAt))")
                print("  CompletedAt: \(String(describing: session.completedAt))")
            } catch {
                print("[WorkoutSession] Error saving updated session: \(error)")
            }
        } else {
            let completedAt = now + TimeInterval(exercise.duration * 60)
            let newSession = WorkoutSession(
                date: today,
                duration: exercise.duration,
                exercises: [exercise],
                startedAt: now,
                completedAt: completedAt
            )
            addWorkoutSession(newSession)
            do {
                try modelContext.save()
                print("[WorkoutSession] Created new session for today:")
                print("  Date: \(newSession.date)")
                print("  Exercises: \(newSession.exercises.map { $0.name }) (1 total)")
                print("  Duration: \(newSession.duration) min")
                print("  StartedAt: \(String(describing: newSession.startedAt))")
                print("  CompletedAt: \(String(describing: newSession.completedAt))")
            } catch {
                print("[WorkoutSession] Error saving new session: \(error)")
            }
        }
    }
}