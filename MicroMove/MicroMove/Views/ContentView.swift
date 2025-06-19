import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var exercises: [Exercise] = []

    var body: some View {
        NavigationView {
            List(exercises, id: \.id) { exercise in
                Text(exercise.name)
            }
            .navigationTitle("Exercises")
            .onAppear {
                fetchExercises()
            }
        }
    }

    private func fetchExercises() {
        do {
            let descriptor = FetchDescriptor<Exercise>()
            exercises = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch exercises: \(error)")
            exercises = []
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Exercise.self, inMemory: true)
}