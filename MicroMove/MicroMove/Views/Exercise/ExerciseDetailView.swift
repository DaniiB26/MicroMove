import SwiftUI

/// Displays detailed information about a single exercise.
struct ExerciseDetailView: View {
    let exercise: Exercise
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var exerciseViewModel: ExercisesViewModel
    @State private var showTimer = false
    @State private var currentGuideIndex = 0
    var activityMonitor: ActivityMonitor? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Main Info Card
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 12) {
                        Text(exercise.name)
                            .font(.largeTitle).bold()
                            .foregroundColor(.accentColor)
            Text(exercise.exerciseDesc)
                .font(.body)
                            .foregroundColor(.primary)
                        HStack(spacing: 16) {
                            Label("\(exercise.type.rawValue.capitalized)", systemImage: "bolt.heart")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Label("\(exercise.bodyPart.rawValue.capitalized)", systemImage: "figure.strengthtraining.traditional")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Label("\(exercise.duration) min", systemImage: "timer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)).shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2))
            Spacer()
                }

                // Completion Status Indicator
                HStack(spacing: 8) {
                    if exercise.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Completed")
                            .foregroundColor(.green)
                            .font(.headline)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                        Text("Not Completed")
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                }
                .padding(.bottom, 4)
                
                if !exercise.visualGuide.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Exercise Guide")
                            .font(.title3).bold()
                            .foregroundColor(.accentColor)
                        Image(exercise.visualGuide[currentGuideIndex])
                            .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .shadow(radius: 8)
                            .onTapGesture {
                                // Advance to next image, loop back to start
                                currentGuideIndex = (currentGuideIndex + 1) % exercise.visualGuide.count
                            }
                        Text("Step \(currentGuideIndex + 1) of \(exercise.visualGuide.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                if !exercise.instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.title3).bold()
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Text("\(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.accentColor)
                                    }
                                    Text(step)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
                Divider().padding(.vertical, 8)

                Button (action: {
                    exerciseViewModel.markExerciseAsDone(exercise)
                }) {
                    Label("Mark as Done", systemImage: "checkmark.circle")
                        .font(.headline)
                .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(10)
                }
                .accessibilityLabel("Mark as Done")

            Button(action: {
                activityLogViewModel.addExerciseStart(exercise: exercise)
                showTimer = true
            }) {
                Label("Start Exercise", systemImage: "play.circle")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(10)
            }
            .accessibilityLabel("Start Exercise")
        }
        .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationDestination(isPresented: $showTimer) {
            TimerView(exercise: exercise, activityLogViewModel: activityLogViewModel, workoutSessionViewModel: workoutSessionViewModel, activityMonitor: activityMonitor, exerciseViewModel: exerciseViewModel)
        }
    }
}
