import SwiftUI

struct OnBoardingPage: View {
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel

    var onFinished: () -> Void = {}

    @State private var selectedLevel: FitnessLevel? = nil
    @State private var selectedGoal: FitnessGoal? = nil
    @State private var showError = false

    var body: some View {
        ZStack {
            // Background
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome!")
                                .font(.largeTitle.bold())
                            Text("Let’s tailor your workouts. Pick your level and your main goal.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title)
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
                    .padding(.top, 12)

                    // Level Card
                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Experience Level")
                            SegmentedLevelPicker(selectedLevel: $selectedLevel)
                        }
                    }

                    // Goal Card
                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Primary Goal")
                            GoalChipsGrid(selectedGoal: $selectedGoal)
                        }
                    }

                    // Tiny hint
                    if selectedLevel == nil || selectedGoal == nil {
                        Text("Tip: You can change these later from Settings.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer(minLength: 80) // space for the bottom bar
                }
                .padding(.vertical, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            // Bottom action bar
            HStack(spacing: 12) {
                Button {
                    onFinished()
                } label: {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondarySoftButton())

                Button {
                    guard let level = selectedLevel, let goal = selectedGoal else {
                        showError = true
                        return
                    }
                    userPreferencesViewModel.fitnessLevel = level
                    userPreferencesViewModel.fitnessGoal = goal
                    userPreferencesViewModel.savePreferences()
                    onFinished()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryFilledButton())
                .disabled(selectedLevel == nil || selectedGoal == nil)
                .opacity((selectedLevel == nil || selectedGoal == nil) ? 0.6 : 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .alert("Please select your level and goal", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }
}

// Level segmented control
private struct SegmentedLevelPicker: View {
    @Binding var selectedLevel: FitnessLevel?

    var body: some View {
        Picker("Experience Level", selection: $selectedLevel) {
            ForEach(FitnessLevel.allCases, id: \.self) { lvl in
                Text(lvl.display).tag(Optional(lvl))
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Experience level")
    }
}

// Goal chips
private struct GoalChipsGrid: View {
    @Binding var selectedGoal: FitnessGoal?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(FitnessGoal.allCases, id: \.self) { goal in
                GoalChip(
                    title: goal.display,
                    icon: iconName(for: goal),
                    isSelected: selectedGoal == goal
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedGoal = goal
                    }
                }
            }
        }
    }

    private func iconName(for goal: FitnessGoal) -> String {
        switch goal {
        case .strength:   return "dumbbell"
        case .cardio, .endurance, .weightLoss: return "bolt.heart"
        case .mobility:   return "figure.cooldown"
        }
    }
}

private struct GoalChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.black : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.black : Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
