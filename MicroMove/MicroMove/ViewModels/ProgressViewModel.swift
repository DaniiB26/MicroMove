import Foundation
import SwiftData

/// ViewModel for managing Progress CRUD operations and state.
@MainActor
class ProgressViewModel: ObservableObject {
    /// The list of all workout sessions, published for UI updates.
    @Published var workoutSessions: [WorkoutSession] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?

    @Published var dailyProgress: [Date: (exercises: Int, duration: Int)] = [:]
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var activeDays: Set<Date> = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refreshProgress()
    }

    /// Fetches all workout sessions from the data store.
    func fetchWorkoutSessions() {
        do {
            let descriptor = FetchDescriptor<WorkoutSession>()
            workoutSessions = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Error fetching workout sessions: \(error.localizedDescription)"
            workoutSessions = []
        }
    }

    /// Refreshes all progress data (sessions, daily progress, streaks, active days)
    func refreshProgress() {
        fetchWorkoutSessions()
        calculateDailyProgress()
        calculateStreaks()
        calculateActiveDays()
    }

    /// Aggregates daily progress from workout sessions
    func calculateDailyProgress() {
        let calendar = Calendar.current
        var progressByDay: [Date: (exercises: Int, duration: Int)] = [:]
        for session in workoutSessions {
            let day = calendar.startOfDay(for: session.date)
            progressByDay[day] = (session.exercises.count, session.duration)
        }
        dailyProgress = progressByDay
    }

    /// Calculates current and longest streaks from daily progress
    func calculateStreaks() {
        let calendar = Calendar.current
        let sortedDays = dailyProgress.keys.sorted()
        var streak = 0
        var maxStreak = 0
        var lastDay: Date?
        for day in sortedDays {
            if let last = lastDay {
                let daysBetween = calendar.dateComponents([.day], from: last, to: day).day ?? 0
                if daysBetween == 1 {
                    streak += 1
                } else if daysBetween > 1 {
                    streak = 1
                }
            } else {
                streak = 1
            }
            maxStreak = max(maxStreak, streak)
            lastDay = day
        }
        currentStreak = streak
        longestStreak = maxStreak
    }

    /// Calculates the set of days with at least one workout session (for calendar views)
    func calculateActiveDays() {
        let calendar = Calendar.current
        activeDays = Set(workoutSessions.map { calendar.startOfDay(for: $0.date) })
    }
}
