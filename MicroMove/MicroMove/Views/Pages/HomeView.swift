import SwiftUI

struct HomeView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @ObservedObject var routineViewModel: RoutineViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            NavigationStack {
                
                    VStack(spacing: 16) {
                        GreetingView(progressViewModel: progressViewModel, userPreferencesViewModel: userPreferencesViewModel)
                        CalendarView(progressViewModel: progressViewModel)
                        Spacer()
                        StartWorkoutButton(destination: RoutineListView(routineViewModel: routineViewModel))
                        Spacer()
                    }
                    .padding(.top, 12)
                
            }
        }
    }
}
