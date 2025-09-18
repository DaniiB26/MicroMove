import SwiftUI

/// Displays detailed information about a single exercise.
struct ExerciseDetailView: View {
    let exercise: Exercise
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var showTimer = false
    @State private var showWeight = false
    @State private var showReps = false
    @State private var currentGuideIndex = 0
    var activityMonitor: ActivityMonitor? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Overview Card
                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(spacing: 4) {
                                Text(exercise.name)
                                    .font(.title3).bold()
                                Text(exercise.exerciseDesc)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Tags row
                        HStack(spacing: 8) {
                            tag(text: exercise.type.rawValue)
                            tag(text: exercise.bodyPart.rawValue)
                            tag(text: exercise.difficulty.display)
                            tag(text: "\(exercise.duration) min")
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 1)
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        ExerciseGuideSheet(
                            images: exercise.visualGuide,
                            startIndex: currentGuideIndex,
                            embedded: true
                        )
                        .padding(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 1)
                    .padding(.horizontal, 16)

                    // Instructions Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 12) {
                                    stepBadge(number: idx + 1)
                                    Text(step)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 1)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    activityLogViewModel.addExerciseStart(exercise: exercise)
                    if exercise.supportsWeight {
                        showWeight = true
                    }
                    else if exercise.supportsReps {
                        showReps = true
                    }
                    else {showTimer = true}
                } label: {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFilledButton())

                Button {
                    if !exercise.isCompleted {
                        exerciseViewModel.markExerciseAsDone(exercise)
                    }
                } label: {
                    Text(exercise.isCompleted ? "Already Completed" : "Mark as Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondarySoftButton())
                .disabled(exercise.isCompleted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white)
        }
        .navigationDestination(isPresented: $showTimer) {
            TimerView(
                exercise: exercise,
                activityLogViewModel: activityLogViewModel,
                workoutSessionViewModel: workoutSessionViewModel,
                activityMonitor: activityMonitor,
                exerciseViewModel: exerciseViewModel,
                progressViewModel: progressViewModel
            )
        }
        .navigationDestination(isPresented: $showReps) {
            RepsView(
                exercise: exercise,
                activityLogViewModel: activityLogViewModel,
                workoutSessionViewModel: workoutSessionViewModel,
                activityMonitor: activityMonitor,
                exerciseViewModel: exerciseViewModel,
                progressViewModel: progressViewModel
            )
        }
        .navigationDestination(isPresented: $showWeight) {
            WeightView(
                exercise: exercise,
                activityLogViewModel: activityLogViewModel,
                workoutSessionViewModel: workoutSessionViewModel,
                activityMonitor: activityMonitor,
                exerciseViewModel: exerciseViewModel,
                progressViewModel: progressViewModel
            )
        }
    }

    // MARK: - UI helpers
    private func tag(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.12))
            .clipShape(Capsule())
    }


    private func stepBadge(number: Int) -> some View {
        Text("\(number)")
            .font(.caption.weight(.bold))
            .foregroundColor(.white)
            .frame(width: 22, height: 22)
            .background(Circle().fill(Color.accentColor))
            .padding(.top, 2)
    }
}
