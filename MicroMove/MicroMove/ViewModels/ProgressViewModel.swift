import Foundation
import SwiftData

/// ViewModel for managing Progress CRUD operations and state.
@MainActor
class ProgressViewModel: ObservableObject {
    /// The list of all workout sessions, published for UI updates.
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var achievements: [Achievement] = []
    /// Error message for UI display, if any operation fails.
    @Published var errorMessage: String?
    @Published var lastUnlockedAchievement: Achievement?

    @Published var dailyProgress: [Date: (exercises: Int, duration: Int)] = [:]
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var activeDays: Set<Date> = []

    private var modelContext: ModelContext
    private var achievementsViewModel: AchievementsViewModel

    init(modelContext: ModelContext, achievementsViewModel: AchievementsViewModel) {
        self.modelContext = modelContext
        self.achievementsViewModel = achievementsViewModel
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
        checkForAchievements()
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

    /// Returns all workout sessions for a given day
    func sessions(for day: Date) -> [WorkoutSession] {
        let calendar = Calendar.current
        return workoutSessions.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    /// Returns total exercises and duration for the current week
    func weeklyStats() -> (exercises: Int, duration: Int) {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return (0, 0) }
        let weekSessions = workoutSessions.filter { weekInterval.contains($0.date) }
        let totalExercises = weekSessions.reduce(0) { $0 + $1.exercises.count }
        let totalDuration = weekSessions.reduce(0) { $0 + $1.duration }
        return (totalExercises, totalDuration)
    }

    /// Returns total exercises and duration for the current month
    func monthlyStats() -> (exercises: Int, duration: Int) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return (0, 0) }
        let monthSessions = workoutSessions.filter { monthInterval.contains($0.date) }
        let totalExercises = monthSessions.reduce(0) { $0 + $1.exercises.count }
        let totalDuration = monthSessions.reduce(0) { $0 + $1.duration }
        return (totalExercises, totalDuration)
    }

    func checkForAchievements() {
        // Ensure achievements are up-to-date
        achievementsViewModel.fetchAchievements()
        achievements = achievementsViewModel.achievements
        let totalExercises = workoutSessions.reduce(0) { $0 + $1.exercises.count }
        let totalMinutes = workoutSessions.reduce(0) { $0 + $1.duration }
        var newlyUnlocked: Achievement? = nil
        for achievement in achievements {
            guard !achievement.isUnlocked else { continue }
            let requirementMet: Bool
            switch achievement.type {
            case .streak:
                requirementMet = currentStreak >= achievement.requirement
            case .totalExercises:
                requirementMet = totalExercises >= achievement.requirement
            case .totalMinutes:
                requirementMet = totalMinutes >= achievement.requirement
            }
            if requirementMet {
                achievement.isUnlocked = true
                achievement.unlockedAt = Date()
                achievementsViewModel.updateAchievement(achievement)
                newlyUnlocked = achievement
            }
        }
        if let unlocked = newlyUnlocked {
            lastUnlockedAchievement = unlocked
            // Reset after a short delay to allow repeated unlocks
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if self.lastUnlockedAchievement?.id == unlocked.id {
                    self.lastUnlockedAchievement = nil
                }
            }
        }
    }
}
