import Foundation
import SwiftData

/// ViewModel for managing UserPreferences CRUD operations and state.
@MainActor
class UserPreferencesViewModel: ObservableObject {

    @Published var reminderInterval: Int = 30
    @Published var reminderTime: Date = Date()
    @Published var quietHoursStart: Date = Date()
    @Published var quietHoursEnd: Date = Date()

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
            if let prefs = try modelContext.fetch(descriptor).first {
                userPreferences = prefs
                reminderInterval = prefs.reminderInterval
                reminderTime = prefs.reminderTime
                quietHoursStart = prefs.quietHoursStart
                quietHoursEnd = prefs.quietHoursEnd
            } else {
                userPreferences = nil
            }
        } catch {
            errorMessage = "Error fetching user preferences: \(error.localizedDescription)"
            userPreferences = nil
        }
    }

    /// Saves the current values to the user's preferences in the data store.
    func savePreferences() {
        if let prefs = userPreferences {
            prefs.reminderInterval = reminderInterval
            prefs.reminderTime = reminderTime
            prefs.quietHoursStart = quietHoursStart
            prefs.quietHoursEnd = quietHoursEnd
        } else {
            let prefs = UserPreferences(
                reminderInterval: reminderInterval,
                reminderTime: reminderTime,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd
            )
            modelContext.insert(prefs)
            userPreferences = prefs
        }
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Error saving user preferences: \(error.localizedDescription)"
        }
    }

    /// Adds new user preferences to the data store and updates the property.
    func addUserPreferences(_ preferences: UserPreferences) {
        modelContext.insert(preferences)
        userPreferences = preferences
    }

    /// Updates the user's preferences. (Deprecated: use savePreferences instead)
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