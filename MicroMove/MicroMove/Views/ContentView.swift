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
    @State private var activityMonitor: ActivityMonitor? = nil

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        _activityLogViewModel = StateObject(wrappedValue: ActivityLogViewModel(modelContext: modelContext))
        _userPreferencesViewModel = StateObject(wrappedValue: UserPreferencesViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            // Show the exercise list with filtering and sorting
            ExerciseListView(exerciseViewModel: ExercisesViewModel(modelContext: modelContext), activityLogViewModel: activityLogViewModel)

            NavigationLink(
                destination: AchievementListView(
                    viewModel: AchievementsViewModel(modelContext: modelContext)
                ),
                isActive: $showAchievements
            ) {
                EmptyView()
            }

            NavigationLink(
                destination: ActivityListView(
                    viewModel: ActivityLogViewModel(modelContext: modelContext)
                ),
                isActive: $showActivityLog
            ) {
                EmptyView()
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(
                        destination: ProgressView(viewModel: ProgressViewModel(modelContext: modelContext)) 
                    )
                    {
                        Image(systemName: "person")
                    }
                    .accessibilityLabel("Progress")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Achievements") {
                            showAchievements = true
                        }
                        Button("Activity Log") {
                            showActivityLog = true
                        }
                        Button("Test Reminder") {
                            activityMonitor?.checkAndScheduleReminder()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: UserPreferencesView(
                            viewModel: userPreferencesViewModel
                        )
                    ) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("User Preferences")
                }
            }
        }
        .onAppear {
            if activityMonitor == nil {
                activityMonitor = ActivityMonitor(activityLogViewModel: activityLogViewModel, userPreferencesViewModel: userPreferencesViewModel)
                activityMonitor?.requestNotificationPermission()
            }
            if !Self.hasLoggedAppOpen {
                activityLogViewModel.addAppOpen()
                Self.hasLoggedAppOpen = true
            }
            activityMonitor?.checkAndScheduleReminder()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Exercise.self, Achievement.self, ActivityLog.self, Progress.self, UserPreferences.self, WorkoutSession.self)
    ContentView(modelContext: container.mainContext)
}