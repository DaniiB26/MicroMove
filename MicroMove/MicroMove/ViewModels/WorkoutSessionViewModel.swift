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
            print("[WorkoutSessionViewModel] Successfully fetched workout sessions.")
        } catch {
            errorMessage = "Error fetching workout sessions: \(error.localizedDescription)"
            workoutSessions = []
        }
    }

    /// Adds a new workout session to the data store and updates the list.
    func addWorkoutSession(_ session: WorkoutSession) {
        modelContext.insert(session)
        workoutSessions.append(session)
        print("[WorkoutSessionViewModel] Added workout session for date: \(session.date)")
    }

    /// Saves changes to an existing workout session. Call after modifying a session's properties.
    func updateWorkoutSession(_ session: WorkoutSession) {
        do {
            try modelContext.save()
            print("[WorkoutSessionViewModel] Updated workout session for date: \(session.date)")
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
            print("[WorkoutSessionViewModel] Deleted workout session for date: \(session.date)")
        } catch {
            errorMessage = "Error deleting workout session: \(error.localizedDescription)"
        }
    }

    /// Adds an exercise to today's workout session, or creates a new session if none exists.
    func addExerciseToSession(exerciseDTO: ExerciseDTO) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let durationMinutes = exerciseDTO.duration / 60

        let todaySession = workoutSessions.first { calendar.isDate($0.date, inSameDayAs: today) }

        if let session = todaySession {
            session.exercises.append(exerciseDTO)
            session.duration += durationMinutes
            if session.startedAt == nil {
                session.startedAt = exerciseDTO.startedAt
            }
            session.completedAt = exerciseDTO.completedAt
            updateWorkoutSession(session)
        } else {
            let newSession = WorkoutSession(
                date: today,
                duration: durationMinutes,
                exercises: [exerciseDTO],
                startedAt: exerciseDTO.startedAt,
                completedAt: exerciseDTO.completedAt
            )
            addWorkoutSession(newSession)
            do {
                try modelContext.save()
            } catch {
                print("[WorkoutSessionViewModel] Error saving new session: \(error)")
            }
        }
    }

    // Adds a repetition-based exercise to the current session.
    func addRepsExercise(exercise: Exercise, reps: Int) {
        let now = Date()
        let durationSeconds = exercise.duration * 60
        let dto = ExerciseDTO (
            baseExercise: exercise,
            startedAt: now,
            completedAt: now + TimeInterval(durationSeconds),
            duration: durationSeconds,
            reps: reps
        )
        addExerciseToSession(exerciseDTO: dto)
    }

    // Adds a weight-based exercise to the current session.
    func addWeightExercise(exercise: Exercise, weight: Int) {
        let now = Date()
        let durationSeconds = exercise.duration * 60
        let dto = ExerciseDTO(
            baseExercise: exercise,
            startedAt: now,
            completedAt: now + TimeInterval(durationSeconds),
            duration: durationSeconds,
            weight: weight
        )
        addExerciseToSession(exerciseDTO: dto)
    }

    // Adds a timed exercise to the current session, capturing actual time spent and whether it ended early.
    func addTimedExercise(exercise: Exercise, timeSpent: Int, endedEarly: Bool) {
        let now = Date()
        let dto = ExerciseDTO(
            baseExercise: exercise,
            startedAt: now - TimeInterval(timeSpent),
            completedAt: now,
            duration: timeSpent,
            endedEarly: endedEarly
        )
        addExerciseToSession(exerciseDTO: dto)
    }
}
