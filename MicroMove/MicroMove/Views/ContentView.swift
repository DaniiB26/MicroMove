import SwiftUI
import SwiftData

/// The main entry point for the app, displaying the exercise library.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // Show the exercise list with filtering and sorting
        ExerciseListView(viewModel: ExercisesViewModel(modelContext: modelContext))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exercise.self, inMemory: true)
}