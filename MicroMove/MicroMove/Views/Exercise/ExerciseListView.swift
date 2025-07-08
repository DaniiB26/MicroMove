import SwiftUI

/// Displays a list of exercises with filtering and sorting options.
struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    var activityMonitor: ActivityMonitor? = nil

    var body: some View {
        NavigationStack {
            HStack {
                Text("Exercises")
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                Spacer()
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        exerciseViewModel.isDurationAscending.toggle()
                    }) {
                        HStack {
                            Image(systemName: exerciseViewModel.isDurationAscending ? "arrow.up" : "arrow.down")
                                .font(.system(size: 14))
                            Text("Sort by Duration")
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.trailing)
                    .accessibilityLabel(exerciseViewModel.isDurationAscending ? "Sort ascending by duration" : "Sort descending by duration")
                }
                
                Picker("Select Exercise Type", selection: $exerciseViewModel.selectedType) {
                    Text("All").tag(nil as ExerciseType?)
                    ForEach(ExerciseType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type as ExerciseType?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List(exerciseViewModel.filteredAndSortedExercises, id: \.id) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise, activityLogViewModel: activityLogViewModel, workoutSessionViewModel: workoutSessionViewModel, exerciseViewModel: exerciseViewModel, activityMonitor: activityMonitor)) {
                        ExerciseRowView(exercise: exercise)
                    }
                }

                // Button("Add Exercise") {
                //     let newExercise = Exercise(
                //         name: "Air Bike",
                //         exerciseDesc: "A core exercise that targets the abs and obliques, performed by pedaling your legs in the air while alternating elbow-to-knee touches.",
                //         type: .cardio,
                //         bodyPart: .core,
                //         duration: 2,
                //         isCompleted: false,
                //         image: "airbike_logo",
                //         instructions: ["Lie flat on the floor with your lower back pressed to the ground. For this exercise, you will need to put your hands beside your head. Be careful however to not strain with the neck as you perform it. Now lift your shoulders into the crunch position.", "Bring knees up to where they are perpendicular to the floor, with your lower legs parallel to the floor. This will be your starting position.", "Now simultaneously, slowly go through a cycle pedal motion kicking forward with the right leg and bringing in the knee of the left leg. Bring your right elbow close to your left knee by crunching to the side, as you breathe out.", "Go back to the initial position as you breathe in.", "Crunch to the opposite side as you cycle your legs and bring closer your left elbow to your right knee and exhale.", "Continue alternating in this manner until all of the recommended repetitions for each side have been completed."],
                //         visualGuide: ["airbike_0", "airbike_1"]
                //     )
                //     exerciseViewModel.addExercise(newExercise)
                // }

                // Button("Delete All Exercises") {
                //     exerciseViewModel.deleteAllExercises(modelContext: modelContext)
                // }

                .navigationTitle("Main Menu")
            }
        }
    }
}
