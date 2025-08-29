import SwiftUI
import SwiftData

struct BottomTabBar: View {
    let modelContext: ModelContext
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    var activityMonitor: ActivityMonitor?

    var body: some View {
        TabView {
            // Home tab
            NavigationStack {
                    ZStack {
                        Color(.systemGray6)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            HomeView(progressViewModel: progressViewModel, userPreferencesViewModel: userPreferencesViewModel, routineViewModel: routineViewModel, exercisesViewModel: exercisesViewModel)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            // Workouts tab
            NavigationStack {
                // Text("Workouts View (To be implemented)")
                //     .frame(maxWidth: .infinity, maxHeight: .infinity)
                //     .background(Color(.systemGray6))
                ExerciseListView(
                    exerciseViewModel: exercisesViewModel,
                    activityLogViewModel: activityLogViewModel,
                    workoutSessionViewModel: workoutSessionViewModel,
                    progressViewModel: progressViewModel,
                    userPreferencesViewModel: userPreferencesViewModel,
                    activityMonitor: activityMonitor
                )
            }
            .tabItem {
                Label("Workouts", systemImage: "dumbbell")
            }

            // Achievements tab
            // NavigationStack {
            //     // Text("Achievements View (To be implemented)")
            //     //     .frame(maxWidth: .infinity, maxHeight: .infinity)
            //     //     .background(Color(.systemGray6))
            //     AchievementListView(
            //         viewModel: achievementsViewModel
            //     )
            // }
            AchievementListView(
                viewModel: achievementsViewModel
            )
            .tabItem {
                Label("Achievements", systemImage: "medal")
            }
        }
        .accentColor(.black)
    }
}
