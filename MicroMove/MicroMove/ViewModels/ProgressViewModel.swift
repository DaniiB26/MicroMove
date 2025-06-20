import Foundation
import SwiftData

/// ViewModel for managing Progress CRUD operations and state.
@MainActor
class ProgressViewModel: ObservableObject {
    /// The list of all progress records, published for UI updates.
    @Published var progress: [Progress] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchProgress()
    }

    /// Fetches all progress records from the data store.
    func fetchProgress() {
        do {
            let descriptor = FetchDescriptor<Progress>()
            progress = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error fetching progress: \(error.localizedDescription)"
            progress = []
        }
    }

    /// Adds a new progress record to the data store and updates the list.
    func addProgress(_ progressRecord: Progress) {
        modelContext.insert(progressRecord)
        progress.append(progressRecord)
    }

    /// Saves changes to an existing progress record. Call after modifying a progress's properties.
    func updateProgress(_ progressRecord: Progress) {
        do {
            try modelContext.save()
            // Optionally update the item in the array if needed
        } catch {
            errorMessage = "Error updating progress: \(error.localizedDescription)"
        }
    }

    /// Deletes a progress record from the data store and updates the list.
    func deleteProgress(_ progressRecord: Progress) {
        do {
            modelContext.delete(progressRecord)
            try modelContext.save()
            progress.removeAll { $0.id == progressRecord.id }
        } catch {
            errorMessage = "Error deleting progress: \(error.localizedDescription)"
        }
    }
}
