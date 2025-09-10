import Foundation
import SwiftData
import UserNotifications

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var achievements: [Achievement] = []
    @Published var errorMessage: String?
    @Published var lastUnlockedAchievement: Achievement?

    @Published var dailyProgress: [Date: (exercises: Int, duration: Int)] = [:]
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var activeDays: Set<Date> = []

    private var modelContext: ModelContext
    private var achievementsViewModel: AchievementsViewModel
    private var activityLogViewModel: ActivityLogViewModel

    init(modelContext: ModelContext, achievementsViewModel: AchievementsViewModel, activityLogViewModel: ActivityLogViewModel) {
        self.modelContext = modelContext
        self.achievementsViewModel = achievementsViewModel
        self.activityLogViewModel = activityLogViewModel
        refreshProgress()
    }

    convenience init(modelContext: ModelContext, achievementsViewModel: AchievementsViewModel) {
        let activityLogVM = ActivityLogViewModel(modelContext: modelContext)
        self.init(modelContext: modelContext, achievementsViewModel: achievementsViewModel, activityLogViewModel: activityLogVM)
    }

    func fetchWorkoutSessions() {
        do {
            let descriptor = FetchDescriptor<WorkoutSession>()
            workoutSessions = try modelContext.fetch(descriptor)
            print("[ProgressViewModel] Successfully fetched workout sessions.")
        } catch {
            errorMessage = "Error fetching workout sessions: \(error.localizedDescription)"
            workoutSessions = []
        }
    }

    func refreshProgress() {
        fetchWorkoutSessions()
        calculateDailyProgress()
        calculateStreaks()
        calculateActiveDays()
        checkForAchievements()
        print("[ProgressViewModel] Refreshed all progress data.")
    }

    func calculateDailyProgress() {
        let calendar = Calendar.current
        var progressByDay: [Date: (exercises: Int, duration: Int)] = [:]
        for session in workoutSessions {
            let day = calendar.startOfDay(for: session.date)
            progressByDay[day] = (
                session.exercises.count,
                session.duration
            )
        }
        dailyProgress = progressByDay
        print("[ProgressViewModel] Calculated daily progress.")
    }

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
        print("[ProgressViewModel] Calculated streaks. Current: \(currentStreak), Longest: \(longestStreak)")
    }

    func calculateActiveDays() {
        let calendar = Calendar.current
        activeDays = Set(workoutSessions.map { calendar.startOfDay(for: $0.date) })
        print("[ProgressViewModel] Calculated active days.")
    }

    func sessions(for day: Date) -> [WorkoutSession] {
        let calendar = Calendar.current
        return workoutSessions.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    func weeklyStats() -> (exercises: Int, duration: Int) {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return (0, 0) }
        let weekSessions = workoutSessions.filter { weekInterval.contains($0.date) }
        let totalExercises = weekSessions.reduce(0) { $0 + $1.exercises.count }
        let totalDuration = weekSessions.reduce(0) { $0 + $1.duration }
        return (totalExercises, totalDuration)
    }

    func monthlyStats() -> (exercises: Int, duration: Int) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return (0, 0) }
        let monthSessions = workoutSessions.filter { monthInterval.contains($0.date) }
        let totalExercises = monthSessions.reduce(0) { $0 + $1.exercises.count }
        let totalDuration = monthSessions.reduce(0) { $0 + $1.duration }
        return (totalExercises, totalDuration)
    }

    func checkForAchievements() {
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
                requirementMet = max(currentStreak, longestStreak) >= achievement.requirement
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
            print("[ProgressViewModel] Unlocked achievement: \(unlocked.title)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if self.lastUnlockedAchievement?.id == unlocked.id {
                    self.lastUnlockedAchievement = nil
                }
            }

            let content = UNMutableNotificationContent()
            content.title = "Achievement Unlocked!"
            content.body = "\(unlocked.title): \(unlocked.achievementDesc)"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let service = NotificationService()
            service.scheduleNotification(identifier: NotificationIdentifiers.achievementUnlocked, content: content, trigger: trigger) { error in
                if let error = error {
                    print("[ProgressViewModel] Failed to schedule achievement notification: \(error.localizedDescription)")
                }
            }

            activityLogViewModel.addAchievementUnlocked(achievement: unlocked)
        }
    }

    func recentExercises(limit: Int = 5, uniqueByExercise: Bool = true) -> [Exercise] {
        var items: [(exercise: Exercise, key: Date)] = []

        for session in workoutSessions {
            for dto in session.exercises {
                let key = dto.completedAt ?? dto.startedAt ?? session.date
                items.append((dto.baseExercise, key))
            }
        }

        let sorted = items.sorted { $0.key > $1.key }.map { $0.exercise }

        if uniqueByExercise {
            var seen: Set<UUID> = []
            var unique: [Exercise] = []
            for ex in sorted {
                if !seen.contains(ex.id) {
                    seen.insert(ex.id)
                    unique.append(ex)
                    if unique.count == limit { break }
                }
            }
            return unique
        } else {
            return Array(sorted.prefix(limit))
        }
    }
}
