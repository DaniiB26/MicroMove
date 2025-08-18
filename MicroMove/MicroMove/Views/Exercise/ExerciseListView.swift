import SwiftUI

/// Displays a list of exercises with filtering and sorting options.
struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    var activityMonitor: ActivityMonitor? = nil

    private var filteredExercises: [Exercise] {
        exerciseViewModel.filteredAndSortedExercises
    }

    private var displayedExercises: [Exercise] {
        if exerciseViewModel.selectedType == nil {
            return progressViewModel.recentExercises(limit: 20, uniqueByExercise: true)
            // let source = exerciseViewModel.exercises
            // let prefs  = userPreferencesViewModel.userPreferences
            // let recommended = (prefs != nil) ? exerciseViewModel.getRecommendedExercises(from: source, prefs: prefs!) : source
            // return recommended
        } else {
            return exerciseViewModel.filteredAndSortedExercises
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                //TITLE
                HStack {
                    Text("RECENT WORKOUTS")
                        .font(.custom("DotGothic16", size: 36))
                        .foregroundColor(.black)
                        .padding()
                    Spacer()
                }
                
                //SORTER
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
                
                // List(exerciseViewModel.filteredAndSortedExercises, id: \.id) { exercise in
                //     NavigationLink(destination: ExerciseDetailView(exercise: exercise, activityLogViewModel: activityLogViewModel, workoutSessionViewModel: workoutSessionViewModel, exerciseViewModel: exerciseViewModel, progressViewModel: progressViewModel, activityMonitor: activityMonitor)) {
                //         ExerciseRowView(exercise: exercise)
                //     }
                // }

                //EXERCISE CARDS
                ScrollView {
                    VStack(spacing: 16) {
                        if displayedExercises.isEmpty {
                            Text(exerciseViewModel.selectedType == nil
                                 ? "No recent workouts yet."
                                 : "No exercises for this filter.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            ForEach(displayedExercises, id: \.id) { exercise in
                                NavigationLink(
                                    destination: ExerciseDetailView(
                                        exercise: exercise,
                                        activityLogViewModel: activityLogViewModel,
                                        workoutSessionViewModel: workoutSessionViewModel,
                                        exerciseViewModel: exerciseViewModel,
                                        progressViewModel: progressViewModel,
                                        activityMonitor: activityMonitor
                                    )
                                ) {
                                    ExerciseCardView(exercise: exercise)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.top)
                }

                //FILTER PICKER
                CustomPicker(selectedType: $exerciseViewModel.selectedType)

                Spacer()

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
                //     let newExercise1 = Exercise(
                //         name: "Push-Up",
                //         exerciseDesc: "A basic push-up",
                //         type: .strength,
                //         bodyPart: .chest,
                //         duration: 1,
                //         isCompleted: false,
                //         image: "pushup_logo",
                //         instructions: ["Lie on the floor face down and place your hands about 36 inches apart while holding your torso up at arms length.", "Next, lower yourself downward until your chest almost touches the floor as you inhale.", "Now breathe out and press your upper body back up to the starting position while squeezing your chest.", "After a brief pause at the top contracted position, you can begin to lower yourself downward again for as many repetitions as needed."],
                //         visualGuide: ["pushups_0", "pushups_1"] 
                //     )
                //     exerciseViewModel.addExercise(newExercise)
                //     exerciseViewModel.addExercise(newExercise1)
                // }

                // Button("Delete All Exercises") {
                //     exerciseViewModel.deleteAllExercises(modelContext: modelContext)
                // }
            }
        }
        .background(Color(.systemGray6))
    }
}
