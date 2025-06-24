import SwiftUI
import SwiftData

/// The main entry point for the app, displaying the exercise library.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showAchievements = false

    var body: some View {
        NavigationStack {
            // Show the exercise list with filtering and sorting
            ExerciseListView(viewModel: ExercisesViewModel(modelContext: modelContext))

            NavigationLink(
                destination: AchievementListView(
                    viewModel: AchievementsViewModel(modelContext: modelContext)
                ),
                isActive: $showAchievements
            ) {
                EmptyView()
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(
                        destination: ProgressView(viewModel: ProgressViewModel(modelContext: modelContext)) 
                    )
                    {
                        Image(systemName: "person")
                    }
                    .accessibilityLabel("Progress")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Achievements") {
                            showAchievements = true
                        }
                        Button("Activity Log", action: {print("Activity Log Selected")}) 
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: UserPreferencesView(
                            viewModel: UserPreferencesViewModel(modelContext: modelContext)
                        )
                    ) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("User Preferences")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exercise.self, inMemory: true)
}