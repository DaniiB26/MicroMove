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

    func seedDefaultExercisesIfNeeded() {
        let flagKey = "didSeedDefaultExercises"
        if UserDefaults.standard.bool(forKey: flagKey) {
            return
        }
        // If store already has exercises, don't seed.
        if !exercises.isEmpty { return }

        let airBike = Exercise(
            name: "Air Bike",
            exerciseDesc: "A core exercise that targets the abs and obliques, performed by pedaling your legs in the air while alternating elbow-to-knee touches.",
            type: .cardio,
            bodyPart: .core,
            difficulty: .beginner,
            duration: 2,
            isCompleted: false,
            image: "Air_Bike/0.jpg",
            instructions: [
                "Lie flat on the floor with your lower back pressed to the ground. For this exercise, you will need to put your hands beside your head. Be careful however to not strain with the neck as you perform it. Now lift your shoulders into the crunch position.",
                "Bring knees up to where they are perpendicular to the floor, with your lower legs parallel to the floor. This will be your starting position.",
                "Now simultaneously, slowly go through a cycle pedal motion kicking forward with the right leg and bringing in the knee of the left leg. Bring your right elbow close to your left knee by crunching to the side, as you breathe out.",
                "Go back to the initial position as you breathe in.",
                "Crunch to the opposite side as you cycle your legs and bring closer your left elbow to your right knee and exhale.",
                "Continue alternating in this manner until all of the recommended repetitions for each side have been completed."
            ],
            visualGuide: ["Air_Bike/0.jpg", "Air_Bike/1.jpg"],
            supportsReps: false,
            supportsWeight: false,
            supportsTimer: true
        )

        let pushUp = Exercise(
            name: "Push-Up",
            exerciseDesc: "A basic push-up",
            type: .strength,
            bodyPart: .chest,
            difficulty: .beginner,
            duration: 1,
            isCompleted: false,
            image: "Pushups/0.jpg",
            instructions: [
                "Lie on the floor face down and place your hands about 36 inches apart while holding your torso up at arms length.",
                "Next, lower yourself downward until your chest almost touches the floor as you inhale.",
                "Now breathe out and press your upper body back up to the starting position while squeezing your chest.",
                "After a brief pause at the top contracted position, you can begin to lower yourself downward again for as many repetitions as needed."
            ],
            visualGuide: ["Pushups/0.jpg", "Pushups/1.jpg"],
            supportsReps: true,
            supportsWeight: false,
            supportsTimer: false
        )

        let curls = Exercise(
            name: "Dumbbell Bicep Curl",
            exerciseDesc: "A basic arm exercise where you curl dumbbells upward to work the biceps.",
            type: .strength,
            bodyPart: .arms,
            difficulty: .beginner,
            duration: 2,
            isCompleted: false,
            image: "Dumbbell_Bicep_Curl/0.jpg",
            instructions: [
                "Stand up straight with a dumbbell in each hand at arm's length. Keep your elbows close to your torso and rotate the palms of your hands until they are facing forward. This will be your starting position.",
                "Now, keeping the upper arms stationary, exhale and curl the weights while contracting your biceps. Continue to raise the weights until your biceps are fully contracted and the dumbbells are at shoulder level. Hold the contracted position for a brief pause as you squeeze your biceps.",
                "Then, inhale and slowly begin to lower the dumbbells back to the starting position.",
                "Repeat for the recommended amount of repetitions."
            ],
            visualGuide: ["Dumbbell_Bicep_Curl/0.jpg", "Dumbbell_Bicep_Curl/1.jpg"],
            supportsReps: false,
            supportsWeight: true,
            supportsTimer: false
        )

        addExercise(airBike)
        addExercise(pushUp)
        addExercise(curls)
        // Persist to store
        try? modelContext.save()
        UserDefaults.standard.set(true, forKey: flagKey)
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
