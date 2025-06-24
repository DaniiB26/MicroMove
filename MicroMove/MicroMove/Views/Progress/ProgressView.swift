import SwiftUI

struct ProgressView: View {
    @ObservedObject var viewModel: ProgressViewModel

    // Returns all days in the current month for the calendar
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let today = Date()
        guard let range = calendar.range(of: .day, in: .month, for: today),
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return []
        }
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }

    // Returns a set of days with at least one workout session
    private var activeDays: Set<Date> {
        guard let progress = viewModel.progress.first else { return [] }
        let calendar = Calendar.current
        return Set(progress.workoutSessions.map { session in
            calendar.startOfDay(for: session.date)
        })
    }

    // Returns a formatted label for the current month
    private var monthLabel: String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: today)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Progress summary section
            if let progress = viewModel.progress.first {
                Text("Exercises Completed: \(progress.exercisesCompleted)")
                Text("Total Minutes: \(progress.totalMinutes)")
                Text("Current Streak: \(progress.currentStreak)")
                Text("Longest Streak: \(progress.longestStreak)")
                // Show achievements if available
                if !progress.achievements.isEmpty {
                    Text("Achievements:")
                        .font(.headline)
                    ForEach(progress.achievements, id: \.id) { achievement in
                        HStack {
                            Text(achievement.title)
                            if achievement.isUnlocked {
                                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                            }
                        }
                        .font(.subheadline)
                    }
                }
            } else {
                Text("No progress data available")
            }

            // Month label and calendar
            Text(monthLabel)
                .font(.headline)
                .padding(.top)
            SimpleCalendarView(daysInMonth: daysInMonth, activeDays: activeDays)
        }
        .padding()
    }
}