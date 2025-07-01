import SwiftUI

/// Displays detailed information about a single exercise.
struct ExerciseDetailView: View {
    let exercise: Exercise
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @State private var showTimer = false
    var activityMonitor: ActivityMonitor? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise.exerciseDesc)
                .font(.body)
            Text("Type: \(exercise.type.rawValue.capitalized)")
            Text("Body Part: \(exercise.bodyPart.rawValue.capitalized)")
            Text("Duration: \(exercise.duration) minutes")
            if !exercise.image.isEmpty {
                Image(exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            Spacer()
            
            Button(action: {
                activityLogViewModel.addExerciseStart(exercise: exercise)
                showTimer = true
            }) {
                Label("Start Exercise", systemImage: "play.circle")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
            }
            .accessibilityLabel("Start Exercise")
            
            Spacer()
        }
        .padding()
        .navigationTitle(exercise.name)
        .navigationDestination(isPresented: $showTimer) {
            TimerView(exercise: exercise, activityLogViewModel: activityLogViewModel, workoutSessionViewModel: workoutSessionViewModel, activityMonitor: activityMonitor)
        }
    }
}
