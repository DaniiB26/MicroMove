import Foundation
import SwiftData

class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAchievements() {
        do {
            let descriptor = FetchDescriptor<Achievement>()
            achievements = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching achievements: \(error)")
            achievements = []
        }
    }

    func addAchievement(_ achievement: Achievement) {
        do {
            try modelContext.insert(achievement)
            fetchAchievements()
        } catch {
            print("Error inserting achievement: \(error)")
        }
    }

    func updateAchievement(_ achievement: Achievement) {
        do {
            try modelContext.save()
            fetchAchievements()
        } catch {
            print("Error updating achievement: \(error)")
        }
    }

    func deleteAchievement(_ achievement: Achievement) {
        do {
            modelContext.delete(achievement)
            try modelContext.save()
            fetchAchievements()
        } catch {
            print("Error deleting achievement: \(error)")
        }
    }
}