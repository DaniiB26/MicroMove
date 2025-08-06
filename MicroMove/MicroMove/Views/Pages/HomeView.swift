import SwiftUI

struct HomeView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            NavigationStack {
                
                    VStack(spacing: 16) {
                        GreetingView(progressViewModel: progressViewModel, userPreferencesViewModel: userPreferencesViewModel)
                        CalendarView(progressViewModel: progressViewModel)
                        Spacer()
                        StartWorkoutButton()
                        Spacer()
                    }
                    .padding(.top, 12)
                
            }
        }
    }
}
