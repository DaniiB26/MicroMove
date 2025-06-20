import Foundation
import SwiftData

/// ViewModel for managing UserPreferences CRUD operations and state.
@MainActor
class UserPreferencesViewModel: ObservableObject {
    /// The user's preferences, published for UI updates.
    @Published var userPreferences: UserPreferences?
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchUserPreferences()
    }

    /// Fetches the user's preferences from the data store.
    func fetchUserPreferences() {
        do {
            let descriptor = FetchDescriptor<UserPreferences>()
            userPreferences = try modelContext.fetch(descriptor).first
        } catch {
            errorMessage = "Error fetching user preferences: \(error.localizedDescription)"
            userPreferences = nil
        }
    }

    /// Adds new user preferences to the data store and updates the property.
    func addUserPreferences(_ preferences: UserPreferences) {
        modelContext.insert(preferences)
        userPreferences = preferences
    }

    /// Saves changes to the user's preferences. Call after modifying properties.
    func updateUserPreferences(_ preferences: UserPreferences) {
        do {
            try modelContext.save()
            // Optionally update the property if needed
        } catch {
            errorMessage = "Error updating user preferences: \(error.localizedDescription)"
        }
    }

    /// Deletes the user's preferences from the data store and updates the property.
    func deleteUserPreferences(_ preferences: UserPreferences) {
        do {
            modelContext.delete(preferences)
            try modelContext.save()
            userPreferences = nil
        } catch {
            errorMessage = "Error deleting user preferences: \(error.localizedDescription)"
        }
    }
}