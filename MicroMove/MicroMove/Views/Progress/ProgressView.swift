import SwiftUI

struct ProgressView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @State private var selectedDay: Date? = nil

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
        viewModel.activeDays
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
            // List(viewModel.dailyProgress.sorted(by: { $0.key > $1.key }), id: \.key) { day, stats in
            //     HStack {
            //         Text(day, style: .date)
            //         Spacer()
            //         Text("\(stats.exercises) exercises")
            //         Text("\(stats.duration) min")
            //     }
            // }

            Text("Current Streak: \(viewModel.currentStreak) day/s")
            Text("Longest Streak: \(viewModel.longestStreak) day/s")

            // Month label and calendar
            Text(monthLabel)
                .font(.headline)
                .padding(.top)
            SimpleCalendarView(daysInMonth: daysInMonth, activeDays: activeDays, onDaySelected: {day in selectedDay = day })

            if let selectedDay = selectedDay,
               let session = viewModel.workoutSessions.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Details for \(selectedDay, style: .date)")
                        .font(.headline)
                    Text("Exercises: \(session.exercises.map { $0.name }.joined(separator: ", "))")
                    Text("Duration: \(session.duration) min")
                    if let startedAt = session.startedAt {
                        Text("Started: \(startedAt, style: .time)")
                    }
                    if let completedAt = session.completedAt {
                        Text("Completed: \(completedAt, style: .time)")
                    } 
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.refreshProgress()
        }
    }
}