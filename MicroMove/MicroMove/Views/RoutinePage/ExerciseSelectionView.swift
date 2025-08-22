import SwiftUI
import SwiftData

/// Allows the user to browse all exercises and add them to a routine.
struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel

    @State private var allExercises: [Exercise] = []
    @State private var recommendedExercises: [Exercise] = []

    var body: some View {
        NavigationStack {
            List {
                if !recommendedExercises.isEmpty {
                    Section("Recommended") {
                        ForEach(recommendedExercises, id: \.id) { ex in
                            exerciseRow(for: ex)
                        }
                    }
                }
                Section("All Exercises") {
                    ForEach(allExercises.filter { ex in !recommendedExercises.contains(where: { $0.id == ex.id }) }, id: \.id) { ex in
                        exerciseRow(for: ex)
                    }
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                fetchExercises()
            }
        }
    }

    private func fetchExercises() {
        do {
            let descriptor = FetchDescriptor<Exercise>()
            let fetched = try modelContext.fetch(descriptor)
            allExercises = fetched
            if let prefs = try modelContext.fetch(FetchDescriptor<UserPreferences>()).first {
                let vm = ExercisesViewModel(modelContext: modelContext)
                recommendedExercises = vm.getRecommendedExercises(from: fetched, prefs: prefs)
            } else {
                recommendedExercises = []
            }
        } catch {
            allExercises = []
            recommendedExercises = []
        }
    }

    private func exerciseRow(for ex: Exercise) -> some View {
        Button(action: {
            routineViewModel.addExercise(routine, ex)
        }) {
            HStack {
                Text(ex.name)
                Spacer()
                if routine.routineExercise.contains(where: { $0.id == ex.id }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}