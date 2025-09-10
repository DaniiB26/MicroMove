import SwiftUI

// View for logging weight used during an exercise.
struct WeightView: View {
    // ViewModels
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var progressViewModel: ProgressViewModel

    // Data
    let exercise: Exercise
    var activityMonitor: ActivityMonitor?

    // UI State
    @State private var weight: Int = 0
    @State private var showError = false
    @FocusState private var weightFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

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
    }

    // MARK: - Actions

    private func bump(_ delta: Int) {
        weight = max(0, weight + delta)
    }

    private func completeExercise() {
        guard weight >= 0 else {
            showError = true
            return
        }
        activityLogViewModel.addExerciseComplete(exercise: exercise)
        workoutSessionViewModel.addWeightExercise(exercise: exercise, weight: weight)
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
                        Image(systemName: "scalemass")
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

                    // Weight card
                    Card {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Weight")
                                .font(.headline)

                            HStack(spacing: 12) {
                                RoundIconButton(systemName: "minus") { bump(-1) }
                                    .disabled(weight == 0)
                                    .opacity(weight == 0 ? 0.5 : 1)

                                TextField("0", value: $weight, format: .number)
                                    .keyboardType(.numberPad)
                                    .focused($weightFieldFocused)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .frame(minWidth: 110)

                                Text("kg")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                RoundIconButton(systemName: "plus") { bump(+1) }
                            }
                            .padding(.vertical, 6)

                            // Quick chips
                            HStack(spacing: 8) {
                                ForEach([+1, +5, +10], id: \.self) { add in
                                    Chip("\(add > 0 ? "+" : "")\(add)") { bump(add) }
                                }
                                Spacer()
                                Chip("Reset") { weight = 0 }
                            }

                            if showError {
                                Text("Please enter a valid weight.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Spacer(minLength: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Exercise Weight")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondarySoftButton())

                Button {
                    completeExercise()
                } label: {
                    Text("Complete")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFilledButton())
                .disabled(weight < 0)
                .opacity(weight < 0 ? 0.6 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .onAppear { weightFieldFocused = true }
    }
}