import SwiftUI
import SwiftData

/// The main entry point for the app, displaying the exercise library.
struct ContentView: View {
    private let modelContext: ModelContext
    @State private var showAchievements = false
    @State private var showActivityLog = false
    @State private static var hasLoggedAppOpen = false
    @StateObject private var activityLogViewModel: ActivityLogViewModel
    @StateObject private var userPreferencesViewModel: UserPreferencesViewModel
    @StateObject private var workoutSessionViewModel: WorkoutSessionViewModel
    @StateObject private var achievementsViewModel: AchievementsViewModel
    @StateObject private var progressViewModel: ProgressViewModel
    @StateObject private var routineViewModel: RoutineViewModel
    @StateObject private var exercisesViewModel: ExercisesViewModel
    @State private var activityMonitor: ActivityMonitor? = nil
    @State private var routineNotificationCoordinator: RoutineNotificationCoordinator? = nil
    @State private var showAchievementBanner = false
    @State private var bannerAchievement: Achievement?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _activityLogViewModel = StateObject(wrappedValue: ActivityLogViewModel(modelContext: modelContext))
        _userPreferencesViewModel = StateObject(wrappedValue: UserPreferencesViewModel(modelContext: modelContext))
        _workoutSessionViewModel = StateObject(wrappedValue: WorkoutSessionViewModel(modelContext: modelContext))
        let achievementsVM = AchievementsViewModel(modelContext: modelContext)
        _achievementsViewModel = StateObject(wrappedValue: achievementsVM)
        _progressViewModel = StateObject(wrappedValue: ProgressViewModel(modelContext: modelContext, achievementsViewModel: achievementsVM))
        _routineViewModel = StateObject(wrappedValue: RoutineViewModel(modelContext: modelContext))
        _exercisesViewModel = StateObject(wrappedValue: ExercisesViewModel(modelContext: modelContext))
    }

    var body: some View {
        ZStack(alignment: .top) {

            BottomTabBar(
                modelContext: modelContext,
                progressViewModel: progressViewModel,
                userPreferencesViewModel: userPreferencesViewModel,
                activityLogViewModel: activityLogViewModel,
                workoutSessionViewModel: workoutSessionViewModel,
                achievementsViewModel: achievementsViewModel,
                routineViewModel: routineViewModel,
                exercisesViewModel: exercisesViewModel,
                activityMonitor: activityMonitor
            )


            // NavigationStack {
            //     VStack(spacing: 16) {
            //         HomeView(progressViewModel: progressViewModel)
            //         BottomTabBar(progressViewModel: progressViewModel)
            //     }
            //     .padding(.horizontal)
            //     .padding(.top, 12)
            //     .frame(maxWidth: .infinity, maxHeight: .infinity)
            //     .background(Color(.systemGray6)) 

                // .toolbar {
                //     ToolbarItem(placement: .navigationBarTrailing){
                //         NavigationLink(
                //             destination: ProgressView(viewModel: progressViewModel)
                //         )
                //         {
                //             Image(systemName: "person")
                //         }
                //         .accessibilityLabel("Progress")
                //     }
                //     ToolbarItem(placement: .navigationBarTrailing) {
                //         Menu {
                //             Button("Achievements") {
                //                 showAchievements = true
                //             }
                //             Button("Activity Log") {
                //                 showActivityLog = true
                //             }
                //         } label: {
                //             Image(systemName: "line.3.horizontal")
                //         }
                //     }
                //     ToolbarItem(placement: .navigationBarTrailing) {
                //         NavigationLink(
                //             destination: UserPreferencesView(
                //                 viewModel: userPreferencesViewModel
                //             )
                //         ) {
                //             Image(systemName: "gearshape")
                //         }
                //         .accessibilityLabel("User Preferences")
                //     }
                // }
            //}
            // if showAchievementBanner, let achievement = bannerAchievement {
            //     HStack(spacing: 12) {
            //         Image(systemName: "star.fill")
            //             .foregroundColor(.black)
            //             .font(.system(size: 28))
            //         VStack(alignment: .leading, spacing: 2) {
            //             Text("Achievement Unlocked!")
            //                 .font(.headline)
            //                 .foregroundColor(.black)
            //             Text(achievement.title)
            //                 .font(.subheadline)
            //                 .foregroundColor(.black)
            //             Text(achievement.achievementDesc)
            //                 .font(.caption)
            //                 .foregroundColor(.black)
            //                 .lineLimit(2)
            //         }
            //         Spacer()
            //     }
            //     .padding()
            //     .background(
            //         Rectangle()
            //             .fill(Color.white)
            //             .cornerRadius(8)
            //             .overlay(
            //                 RoundedRectangle(cornerRadius: 8)
            //                     .stroke(Color.black, lineWidth: 2)
            //             )
            //     )
            //     .frame(
            //         width: UIScreen.main.bounds.width * 0.95,
            //         height: UIScreen.main.bounds.height * 0.13
            //     )
            //     .padding(.top, 16)
            //     .transition(.move(edge: .top))
            //     .onAppear {
            //         // Auto-dismiss after 3 seconds
            //         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //             withAnimation { showAchievementBanner = false }
            //         }
            //     }
            //     .accessibilityElement(children: .combine)
            //     .accessibilityLabel("Achievement Unlocked: \(achievement.title). \(achievement.achievementDesc)")
            // }
            // Floating test button (bottom right)
            // VStack {
            //     Spacer()
            //     HStack {
            //         Spacer()
            //         Button(action: {
            //             bannerAchievement = Achievement(
            //                 title: "Test Streak!",
            //                 achievementDesc: "Completed 7 days in a row.",
            //                 type: .streak,
            //                 requirement: 7,
            //                 isUnlocked: true,
            //                 unlockedAt: Date()
            //             )
            //             withAnimation { showAchievementBanner = true }
            //         }) {
            //             Image(systemName: "wand.and.stars")
            //                 .font(.system(size: 28, weight: .bold))
            //                 .foregroundColor(.white)
            //                 .padding()
            //                 .background(Circle().fill(Color.black))
            //         }
            //         .padding(.trailing, 24)
            //         .padding(.bottom, 32)
            //         .accessibilityLabel("Test Achievement Banner")
            //     }
            // }
        }
        .onAppear {
            if activityMonitor == nil {
                // ActivityMonitor requests notification permission during init
                activityMonitor = ActivityMonitor(activityLogViewModel: activityLogViewModel, userPreferencesViewModel: userPreferencesViewModel)
            }
            if routineNotificationCoordinator == nil {
                routineNotificationCoordinator = RoutineNotificationCoordinator(
                    activityLogViewModel: activityLogViewModel,
                    routines: routineViewModel.routines,
                    exercises: exercisesViewModel.exercises
                )
                routineViewModel.onTriggerChanged = {
                    self.routineNotificationCoordinator?.updateData(
                        routines: self.routineViewModel.routines,
                        exercises: self.exercisesViewModel.exercises
                    )
                    // On config changes, reschedule without immediately firing inactivity/health checks
                    self.routineNotificationCoordinator?.scheduleAllTriggers()
                }
            }
            if !Self.hasLoggedAppOpen {
                activityLogViewModel.addAppOpen()
                Self.hasLoggedAppOpen = true
            }
            activityMonitor?.checkAndScheduleReminder()
            routineNotificationCoordinator?.scheduleAllTriggers()
            
            // Share coordinators with AppDelegate
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                // Ensure AppDelegate uses the same ActivityLogViewModel instance
                appDelegate.activityLogViewModel = activityLogViewModel
                appDelegate.activityMonitor = activityMonitor
                appDelegate.routineNotificationCoordinator = routineNotificationCoordinator
            }
        }
        // .onReceive(progressViewModel.$lastUnlockedAchievement) { achievement in
        //     if let achievement = achievement {
        //         bannerAchievement = achievement
        //         withAnimation { showAchievementBanner = true }
        //     }
        // }
    }
}

#Preview {
    let container = try! ModelContainer(for: Exercise.self, Achievement.self, ActivityLog.self, Progress.self, UserPreferences.self, WorkoutSession.self, Routine.self)
    ContentView(modelContext: container.mainContext)
}
