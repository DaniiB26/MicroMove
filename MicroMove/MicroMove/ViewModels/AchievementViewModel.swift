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
}