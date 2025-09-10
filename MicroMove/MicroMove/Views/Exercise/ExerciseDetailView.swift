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
    @State private var showGuide = false
    var activityMonitor: ActivityMonitor? = nil

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Hero Header
                    ZStack(alignment: .bottom) {
                        headerImage
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.5)],
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            )
                        
                        VStack {
                            // Play Button
                            Button {
                                showGuide = true
                            } label: {
                                Label("Play video", systemImage: "play.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(.black)
                                    .clipShape(Capsule())
                            }
                            .foregroundColor(.white)
                            .padding(.bottom, 14)

                            HStack(spacing: 20) {
                                chip(text: exercise.type.rawValue.capitalized)
                                Spacer()
                                chip(text: exercise.bodyPart.rawValue.capitalized)
                                Spacer()
                                chip(text: "\(exercise.duration) min")
                            }
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(exercise.name) instructions")
                            .font(.title3).bold()
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1).")
                                        .font(.body.weight(.semibold))
                                    Text(step)
                                        .font(.body)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)

        .fullScreenCover(isPresented: $showGuide) {
            ExerciseGuideSheet(
                images: exercise.visualGuide,
                startIndex: currentGuideIndex
            )
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
    private var headerImage: Image {
        if !exercise.image.isEmpty {
            return Image(exercise.image)         
        }
        if let first = exercise.visualGuide.first, !first.isEmpty {
            return Image(first)
        }
        return Image(systemName: "figure.strengthtraining.traditional")
    }

    private func chip(text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 24)
            .clipShape(Capsule())
    }
}

