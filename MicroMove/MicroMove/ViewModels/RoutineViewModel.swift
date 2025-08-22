import Foundation
import SwiftData

@MainActor
class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var errorMessage: String?

    private var modelContext: ModelContext    

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchRoutines() { 
        do {
            let descriptor = FetchDescriptor<Routine>()
            routines = try modelContext.fetch(descriptor)
            print("[RoutineViewModel] Successfully fetched routines.")
        } catch {
            errorMessage = "Error fetching routines: \(error.localizedDescription)"
            routines = []
        }
    }
    
    func addRoutine(_ routine: Routine) {
        modelContext.insert(routine)
        do {
            try modelContext.save()
            routines.append(routine)
        } catch {
            errorMessage = "Error saving new routine: \(error.localizedDescription)"
        }
    }


    func updateRoutine(_ routine: Routine) {
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Error updating routine: \(error.localizedDescription)"
        }
    }

    func deleteRoutine(_ routine: Routine) {
        do {
            modelContext.delete(routine)
            try modelContext.save()
            routines.removeAll { $0.id == routine.id }
        } catch {
            errorMessage = "Error deleting routine: \(error.localizedDescription)"
        }
    }

    func toggleActivateRoutine(_ routine: Routine, _ active: Bool) {
        routine.isActive = active
        save()
        fetchRoutines()
    }

    func addExercise(_ routine: Routine, _ exercise: Exercise) {
        routine.routineExercise.append(exercise)
        save()
        fetchRoutines()
    }

    func removeExercise(_ routine: Routine, _ exercise: Exercise) {
        routine.routineExercise.removeAll {$0.id == exercise.id}
        save()
        fetchRoutines()
    }

    /// Adds a trigger to a routine for a specific exercise (if provided).
    func addTrigger(_ routine: Routine, _ triggerType: TriggerType, exercise: Exercise? = nil, params: [String:String] = [:]) {
        let trigger = RoutineTrigger(triggerType: triggerType, params: params, exercise: exercise)
        routine.routineTriggers.append(trigger)
        save()
        fetchRoutines()
        //TODO: Schedule Trigger?
    }

    func removeTrigger(_ routine: Routine, _ routineTrigger: RoutineTrigger) {
        routine.routineTriggers.removeAll { $0.id == routineTrigger.id }
        save()
        fetchRoutines()
        //TODO: Deactivate Trigger Notifications?
    }

    func save() {
        do { try modelContext.save() }
        catch { errorMessage = "Save error: \(error.localizedDescription)" }
    }

    func deleteAll() {
        do {
            for routine in routines {
                modelContext.delete(routine)
            }
            try modelContext.save()
            routines.removeAll()
        } catch {
            errorMessage = "Error deleting all routines: \(error.localizedDescription)"
        }
    }
}
