import Foundation
import SwiftData

/// ViewModel for managing Achievement CRUD operations and state.
@MainActor
class AchievementsViewModel: ObservableObject {
    /// The list of all achievements, published for UI updates.
    @Published var achievements: [Achievement] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Fetches all achievements from the data store.
    func fetchAchievements() {
        do {
            let descriptor = FetchDescriptor<Achievement>()
            achievements = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error fetching achievements: \(error.localizedDescription)"
            achievements = []
        }
    }

    /// Adds a new achievement to the data store and updates the list.
    func addAchievement(_ achievement: Achievement) {
        modelContext.insert(achievement)
        achievements.append(achievement)
    }

    /// Saves changes to an existing achievement. Call after modifying an achievement's properties.
    func updateAchievement(_ achievement: Achievement) {
        do {
            try modelContext.save()
            // Optionally update the item in the array if needed
        } catch {
            errorMessage = "Error updating achievement: \(error.localizedDescription)"
        }
    }

    /// Deletes an achievement from the data store and updates the list.
    func deleteAchievement(_ achievement: Achievement) {
        do {
            modelContext.delete(achievement)
            try modelContext.save()
            achievements.removeAll { $0.id == achievement.id }
        } catch {
            errorMessage = "Error deleting achievement: \(error.localizedDescription)"
        }
    }

    /// Seeds a default set of achievements on first launch if none exist.
    func seedDefaultAchievementsIfNeeded() {
        let flagKey = "didSeedDefaultAchievements"
        if UserDefaults.standard.bool(forKey: flagKey) { return }

        // Ensure we have the latest snapshot
        fetchAchievements()

        // If store already has achievements, don't seed
        if !achievements.isEmpty { return }

        let streaks = [3, 7, 14, 30, 100]
        let minutes = [10, 30, 60, 120, 300]
        let exercises = [5, 10, 25, 50, 100]

        let allAchievements: [Achievement] =
            streaks.map { Achievement(title: "Streak: \($0) days", achievementDesc: "Complete a workout \($0) days in a row.", type: .streak, requirement: $0) } +
            minutes.map { Achievement(title: "Minutes: \($0)", achievementDesc: "Accumulate \($0) total minutes of exercise.", type: .totalMinutes, requirement: $0) } +
            exercises.map { Achievement(title: "Exercises: \($0)", achievementDesc: "Complete \($0) exercises.", type: .totalExercises, requirement: $0) }

        for achievement in allAchievements {
            // Avoid duplicates by checking title + type
            if !achievements.contains(where: { $0.title == achievement.title && $0.type == achievement.type }) {
                addAchievement(achievement)
            }
        }

        // Persist to store and set flag
        try? modelContext.save()
        UserDefaults.standard.set(true, forKey: flagKey)
    }
}
