import SwiftUI

struct ProgressView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @State private var selectedDay: Date? = nil
    @State private var displayedMonth: Date = Date()

    private var daysInDisplayedMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }

    private var activeDaysInDisplayedMonth: Set<Date> {
        let calendar = Calendar.current
        return activeDays.filter { calendar.isDate($0, equalTo: displayedMonth, toGranularity: .month) }
    }

    private var activeDays: Set<Date> {
        viewModel.activeDays
    }

    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Weekly and monthly stats
                HStack(spacing: 16) {
                    statCard(title: "This Week", stats: viewModel.weeklyStats(), accent: .accentColor)
                    statCard(title: "This Month", stats: viewModel.monthlyStats(), accent: .accentColor)
                }
                .padding(.horizontal)

                Divider()

                // Streaks
                HStack(spacing: 24) {
                    streakView(title: "Current Streak", value: viewModel.currentStreak, color: .green)
                    streakView(title: "Longest Streak", value: viewModel.longestStreak, color: .blue)
                }
                .padding(.horizontal)

                Divider()

                // Month navigation
                HStack {
                    Button(action: {
                        if let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) {
                            displayedMonth = prevMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(monthLabel(for: displayedMonth))
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) {
                            displayedMonth = nextMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                // Calendar + session details
                if let selectedDay = selectedDay {
                    sessionDetailsView(for: selectedDay)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            viewModel.refreshProgress()
        }
    }

    // MARK: - Subviews

    private func statCard(title: String, stats: (exercises: Int, duration: Int), accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(stats.exercises)")
                .font(.title2).bold()
                .foregroundColor(accent)
            Text("Exercises")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(stats.duration) min")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    }

    private func streakView(title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value) day\(value == 1 ? "" : "s")")
                .font(.title3).bold()
                .foregroundColor(color)
        }
    }

    @ViewBuilder
    private func sessionDetailsView(for day: Date) -> some View {
        let sessions = viewModel.sessions(for: day)

        if !sessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Workout Details for \(day, style: .date)")
                    .font(.headline)
                    .padding(.top)
                ForEach(sessions, id: \.id) { session in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercises: \(session.exercises.map { $0.baseExercise.name }.joined(separator: ", "))")
                            .font(.subheadline)
                        Text("Duration: \(session.duration) min")
                            .font(.subheadline)
                        if let startedAt = session.startedAt {
                            Text("Started: \(startedAt, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if let completedAt = session.completedAt {
                            Text("Completed: \(completedAt, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal)
        } else {
            Text("No workout session for this day.")
                .italic()
                .padding()
        }
    }
}
