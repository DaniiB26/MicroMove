import SwiftUI
import SwiftData

/// The main entry point for the app, displaying the exercise library.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            // Show the exercise list with filtering and sorting
            ExerciseListView(viewModel: ExercisesViewModel(modelContext: modelContext))
            .toolbar {
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