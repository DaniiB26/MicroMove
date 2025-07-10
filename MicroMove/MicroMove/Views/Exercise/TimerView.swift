import SwiftUI

struct TimerView: View {
    @State private var isRunning = true
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining: Int
    let exercise: Exercise
    var activityMonitor: ActivityMonitor? // Optional ActivityMonitor for notification reset

    init(exercise: Exercise, activityLogViewModel: ActivityLogViewModel, workoutSessionViewModel: WorkoutSessionViewModel, activityMonitor: ActivityMonitor? = nil, exerciseViewModel: ExercisesViewModel, progressViewModel: ProgressViewModel) {
        self.exercise = exercise
        self.activityLogViewModel = activityLogViewModel
        self.workoutSessionViewModel = workoutSessionViewModel
        self.activityMonitor = activityMonitor
        self.exerciseViewModel = exerciseViewModel
        self.progressViewModel = progressViewModel
        self._timeRemaining = State(initialValue: exercise.duration * 60) // Convert minutes to seconds
    }

    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                completeExercise()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func completeExercise() {
        // Log the completed exercise
        activityLogViewModel.addExerciseComplete(exercise: exercise)
        workoutSessionViewModel.addExerciseToSession(exercise: exercise)
        progressViewModel.refreshProgress()
        // Reset the reminder notification schedule after exercise completion
        activityMonitor?.resetInactivityReminder()
        // Mark the exercise as done
        exerciseViewModel.markExerciseAsDone(exercise)
        // Navigate back to exercise detail view
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Exercise info
            VStack(spacing: 16) {
                Text(exercise.name)
                    .font(.title)
                    .bold()
                
                Text("Duration: \(exercise.duration) minutes")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Timer display
            VStack(spacing: 20) {
                Text("Time Remaining")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(isRunning ? .primary : .green)
            }
            
            Spacer()
            
            // Control buttons
            VStack(spacing: 16) {
                if isRunning {
                    Button("Cancel Exercise") {
                        stopTimer()
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    Text("Exercise Complete!")
                        .font(.title2)
                        .foregroundColor(.green)
                        .bold()
                }
            }
        }
        .padding()
        .navigationTitle("Exercise Timer")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // Helper function to format time as MM:SS
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
