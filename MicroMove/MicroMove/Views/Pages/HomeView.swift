import SwiftUI

struct HomeView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            NavigationStack {
                
                    VStack(spacing: 16) {
                        GreetingView(progressViewModel: progressViewModel, userPreferencesViewModel: userPreferencesViewModel)
                        CalendarView(progressViewModel: progressViewModel)
                        Spacer()
                        StartWorkoutButton(destination: RoutineListView(routineViewModel: routineViewModel, exercisesViewModel: exercisesViewModel, userPreferencesViewModel: userPreferencesViewModel))
                        Spacer()
                    }
                    .padding(.top, 12)
                
            }
        }
    }
}
