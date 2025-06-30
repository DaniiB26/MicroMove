import SwiftUI
import SwiftData

@main
struct MicroMoveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Achievement.self,
            ActivityLog.self,
            Progress.self,
            UserPreferences.self,
            WorkoutSession.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: sharedModelContainer.mainContext)
                .onAppear{
                    // Share ActivityLogViewModel with AppDelegate for notification response logging
                    let activityLogViewModel = ActivityLogViewModel(modelContext: sharedModelContainer.mainContext)
                    appDelegate.activityLogViewModel = activityLogViewModel
                }
        }
        .modelContainer(sharedModelContainer)
    }
}