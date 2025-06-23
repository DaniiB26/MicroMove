import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var exercises: [Exercise] = []

    var body: some View {
        ExerciseListView(viewModel: ExercisesViewModel(modelContext: modelContext))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exercise.self, inMemory: true)
}