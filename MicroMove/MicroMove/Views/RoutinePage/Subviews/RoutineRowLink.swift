import SwiftUI

struct RoutineRowLink: View {
    let routine: Routine
    let onToggle: () -> Void
    let onDelete: () -> Void
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel

    var body: some View {
        NavigationLink {
            RoutineDetailView(routine: routine, routineViewModel: routineViewModel, exercisesViewModel: exercisesViewModel, userPreferencesViewModel: userPreferencesViewModel)
        } label: {
            RoutineRowCard(routine: routine, onToggleActive: onToggle)
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
