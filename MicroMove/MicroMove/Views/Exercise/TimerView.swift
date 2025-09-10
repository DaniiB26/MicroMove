import SwiftUI

struct TimerView: View {
    // ViewModels
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var progressViewModel: ProgressViewModel

    // Data
    let exercise: Exercise
    var activityMonitor: ActivityMonitor?

    // Timer state
    @State private var isRunning = true
    @State private var timer: Timer?
    @State private var endedEarly = false
    @State private var startDate = Date()
    @State private var timeRemaining: Int
    @State private var didComplete = false

    @Environment(\.dismiss) private var dismiss

    private var totalSeconds: Int { exercise.duration * 60 }
    private var progress: CGFloat {
        guard totalSeconds > 0 else { return 1 }
        return CGFloat(max(0, totalSeconds - timeRemaining)) / CGFloat(totalSeconds)
    }

    init(
        exercise: Exercise,
        activityLogViewModel: ActivityLogViewModel,
        workoutSessionViewModel: WorkoutSessionViewModel,
        activityMonitor: ActivityMonitor? = nil,
        exerciseViewModel: ExercisesViewModel,
        progressViewModel: ProgressViewModel
    ) {
        self.exercise = exercise
        self.activityLogViewModel = activityLogViewModel
        self.workoutSessionViewModel = workoutSessionViewModel
        self.activityMonitor = activityMonitor
        self.exerciseViewModel = exerciseViewModel
        self.progressViewModel = progressViewModel
        _timeRemaining = State(initialValue: exercise.duration * 60)
    }

    // MARK: - Timer control

    private func startTimer() {
        guard timer == nil else { return }
        isRunning = true
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                completeExercise()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func completeExercise() {
        guard !didComplete else { return }
        didComplete = true

        let now = Date()
        let timeSpent = Int(now.timeIntervalSince(startDate))

        activityLogViewModel.addExerciseComplete(exercise: exercise)
        workoutSessionViewModel.addTimedExercise(exercise: exercise,
                                                 timeSpent: max(0, timeSpent),
                                                 endedEarly: endedEarly)
        progressViewModel.refreshProgress()
        activityMonitor?.resetInactivityReminder()
        exerciseViewModel.markExerciseAsDone(exercise)
        dismiss()
    }

    // MARK: - UI

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // Header
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exercise.name)
                                .font(.title.bold())
                                .foregroundColor(.primary)
                            Text("Duration: \(exercise.duration) min")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Timer Card with circular progress
                    Card {
                        VStack(spacing: 18) {
                            Text("Time Remaining")
                                .font(.headline)

                            ZStack {
                                // Track
                                Circle()
                                    .stroke(Color.black.opacity(0.08), lineWidth: 16)

                                // Progress
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        Color.black,
                                        style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.2), value: progress)

                                // Time text
                                Text(timeString(from: timeRemaining))
                                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)

                            // Status text
                            Text(isRunning ? "Keep going…" : (timeRemaining == 0 ? "Done!" : "Paused"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Controls card
                    Card {
                        HStack(spacing: 12) {
                            //Pause Button
                            Button {
                                if isRunning {
                                    stopTimer()
                                } else {
                                    startTimer()
                                }
                            } label: {
                                Label(isRunning ? "Pause" : "Resume", systemImage: isRunning ? "pause.fill" : "play.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondarySoftButton())

                            Button(role: .destructive) {
                                endedEarly = true
                                stopTimer()
                                completeExercise()
                            } label: {
                                Label("End Early", systemImage: "xmark.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondarySoftButton())
                        }
                    }
                    .frame(maxWidth: .infinity) 

                    Spacer(minLength: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Exercise Timer")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    // MARK: - Helpers

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}