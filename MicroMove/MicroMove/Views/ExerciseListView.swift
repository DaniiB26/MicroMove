import SwiftUI

/// Displays a list of exercises with filtering and sorting options.
struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: ExercisesViewModel

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.isDurationAscending.toggle()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isDurationAscending ? "arrow.up" : "arrow.down")
                                .font(.system(size: 14))
                            Text("Sort by Duration")
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.trailing)
                    .accessibilityLabel(viewModel.isDurationAscending ? "Sort ascending by duration" : "Sort descending by duration")
                }
                
                Picker("Select Exercise Type", selection: $viewModel.selectedType) {
                    Text("All").tag(nil as ExerciseType?)
                    ForEach(ExerciseType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type as ExerciseType?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List(viewModel.filteredAndSortedExercises, id: \.id) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        ExerciseRowView(exercise: exercise)
                    }
                }
                .navigationTitle("Exercises")
            }
        }
    }
}
