import SwiftUI

// View for logging repetition-based exercises.
struct RepsView: View {
    // ViewModels
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var progressViewModel: ProgressViewModel

    // Data
    let exercise: Exercise
    var activityMonitor: ActivityMonitor?

    // UI State
    @State private var repsText: String = ""
    @FocusState private var repsFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private var repsInt: Int? {
        guard let n = Int(repsText), n >= 0 else { return nil }
        return n
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
    }

    // MARK: - Actions

    private func bump(_ delta: Int) {
        let current = Int(repsText) ?? 0
        let next = max(0, current + delta)
        repsText = String(next)
    }

    private func completeExercise() {
        guard let reps = repsInt, reps > 0 else { return }
        activityLogViewModel.addExerciseComplete(exercise: exercise)
        workoutSessionViewModel.addRepsExercise(exercise: exercise, reps: reps)
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
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exercise.name)
                                .font(.title.bold())
                            Text("Log your reps for this set")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "number")
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

                    // Reps Card
                    Card {
                        VStack(alignment: .center, spacing: 14) {
                            Text("Repetitions")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 12) {
                                RoundIconButton(systemName: "minus") { bump(-1) }
                                    .disabled((Int(repsText) ?? 0) == 0)
                                    .opacity((Int(repsText) ?? 0) == 0 ? 0.5 : 1)

                                TextField("0", text: $repsText)
                                    .keyboardType(.numberPad)
                                    .focused($repsFieldFocused)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .frame(minWidth: 100)
                                    .onChange(of: repsText) { newValue in
                                        let digits = newValue.filter { $0.isNumber }
                                        if digits != newValue { repsText = digits }
                                    }

                                RoundIconButton(systemName: "plus") { bump(+1) }
                            }
                            .padding(.vertical, 6)

                            // Quick chips
                            HStack(spacing: 8) {
                                ForEach([+1, +5, +10], id: \.self) { add in
                                    Chip("\(add > 0 ? "+" : "")\(add)") { bump(add) }
                                }
                                Spacer()
                                Chip("Reset") { repsText = "0" }
                            }

                            // Tiny validation hint
                            if repsInt == nil && !repsText.isEmpty {
                                Text("Please enter digits only.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }

                    // Info Card
                    Card {
                        HStack {
                            Label("\(exercise.duration) min", systemImage: "timer")
                            Spacer()
                            Label(exercise.type.rawValue.capitalized, systemImage: "dumbbell")
                            Spacer()
                            Label(exercise.bodyPart.rawValue.capitalized, systemImage: "figure.walk")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }

                    Spacer(minLength: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Exercise Reps")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Text("Cancel").frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondarySoftButton())

                Button { completeExercise() } label: {
                    Text("Complete").frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFilledButton())
                .disabled((repsInt ?? 0) <= 0)
                .opacity((repsInt ?? 0) > 0 ? 1 : 0.6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .onAppear {
            repsText = "0"
            repsFieldFocused = true
        }
    }
}


// MARK: - Small Reusable Pieces

private struct RoundIconButton: View {
    let systemName: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

private struct Chip: View {
    let title: String
    let action: () -> Void
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}
