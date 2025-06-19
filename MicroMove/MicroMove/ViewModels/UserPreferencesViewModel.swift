import Foundation
import SwiftData

class UserPreferencesViewModel: ObservableObject {
    @Published var userPreferences: UserPreferences?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchUserPreferences()
    }

    func fetchUserPreferences() {
        do {
            let descriptor = FetchDescriptor<UserPreferences>()
            userPreferences = try modelContext.fetch(descriptor).first
        } catch {
            print("Error fetching user preferences: \(error)")
            userPreferences = nil
        }
    }

    func addUserPreferences(_ userPreferences: UserPreferences) {
        do {
            try modelContext.insert(userPreferences)
            fetchUserPreferences()
        } catch {
            print("Error inserting user preferences: \(error)")
        }
    }

    func updateUserPreferences(_ userPreferences: UserPreferences) {
        do {
            try modelContext.save()
            fetchUserPreferences()
        } catch {
            print("Error updating user preferences: \(error)")
        }
    }

    func deleteUserPreferences(_ userPreferences: UserPreferences) {
        do {
            modelContext.delete(userPreferences)
            try modelContext.save()
            fetchUserPreferences()
        } catch {
            print("Error deleting user preferences: \(error)")
        }
    }
}