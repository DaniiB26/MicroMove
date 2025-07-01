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
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise, activityLogViewModel: activityLogViewModel, workoutSessionViewModel: workoutSessionViewModel, activityMonitor: activityMonitor)) {
                        ExerciseRowView(exercise: exercise)
                    }
                }
                .navigationTitle("Main Menu")
            }
        }
    }
}
