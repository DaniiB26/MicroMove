import SwiftUI
import SwiftData

struct BottomTabBar: View {
    enum Tab: Hashable { case home, workouts, achievements, activity }
    let modelContext: ModelContext
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    @ObservedObject var activityLogViewModel: ActivityLogViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    var activityMonitor: ActivityMonitor?
    @State private var selectedTab: Tab

    init(
        modelContext: ModelContext,
        progressViewModel: ProgressViewModel,
        userPreferencesViewModel: UserPreferencesViewModel,
        activityLogViewModel: ActivityLogViewModel,
        workoutSessionViewModel: WorkoutSessionViewModel,
        achievementsViewModel: AchievementsViewModel,
        routineViewModel: RoutineViewModel,
        exercisesViewModel: ExercisesViewModel,
        activityMonitor: ActivityMonitor?,
        initialTab: Tab = .home
    ) {
        self.modelContext = modelContext
        self._progressViewModel = ObservedObject(wrappedValue: progressViewModel)
        self._userPreferencesViewModel = ObservedObject(wrappedValue: userPreferencesViewModel)
        self._activityLogViewModel = ObservedObject(wrappedValue: activityLogViewModel)
        self._workoutSessionViewModel = ObservedObject(wrappedValue: workoutSessionViewModel)
        self._achievementsViewModel = ObservedObject(wrappedValue: achievementsViewModel)
        self._routineViewModel = ObservedObject(wrappedValue: routineViewModel)
        self._exercisesViewModel = ObservedObject(wrappedValue: exercisesViewModel)
        self.activityMonitor = activityMonitor
        self._selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
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
            .tag(Tab.home)

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
            .tag(Tab.workouts)

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
                viewModel: achievementsViewModel,
                progressViewModel: progressViewModel
            )
            .tabItem {
                Label("Achievements", systemImage: "medal")
            }
            .tag(Tab.achievements)

            // Activity Log tab
            ActivityListView(
                viewModel: activityLogViewModel
            )
            .tabItem {
                Label("Activity", systemImage: "clock")
            }
            .tag(Tab.activity)
        }
        .accentColor(.black)
    }
}
