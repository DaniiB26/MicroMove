import Foundation
import SwiftData

class ProgressViewModel: ObservableObject {
    @Published var progress: [Progress] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchProgress()
    }

    func fetchProgress() {
        do {
            let descriptor = FetchDescriptor<Progress>()
            progress = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching progress: \(error)")
            progress = []
        }
    }

    func addProgress(_ progress: Progress) {
        do {
            try modelContext.insert(progress)
            fetchProgress()
        } catch {
            print("Error inserting progress: \(error)")
        }
    }

    func updateProgress(_ progress: Progress) {
        do {
            try modelContext.save()
            fetchProgress()
        } catch {
            print("Error updating progress: \(error)")
        }
    }

    func deleteProgress(_ progress: Progress) {
        do {
            modelContext.delete(progress)
            try modelContext.save()
            fetchProgress()
        } catch {
            print("Error deleting progress: \(error)")
        }
    }
}
