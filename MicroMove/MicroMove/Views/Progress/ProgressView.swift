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

    // Returns a set of days with at least one workout session
    private var activeDays: Set<Date> {
        viewModel.activeDays
    }

    // Returns a formatted label for the current month
    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Weekly and monthly stats in cards
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let weekStats = viewModel.weeklyStats()
                        Text("\(weekStats.exercises)")
                            .font(.title2).bold()
                            .foregroundColor(.accentColor)
                        Text("Exercises")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(weekStats.duration) min")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This Month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let monthStats = viewModel.monthlyStats()
                        Text("\(monthStats.exercises)")
                            .font(.title2).bold()
                            .foregroundColor(.accentColor)
                        Text("Exercises")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(monthStats.duration) min")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                }
                .padding(.horizontal)

                Divider()

                // Streaks
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.currentStreak) day\(viewModel.currentStreak == 1 ? "" : "s")")
                            .font(.title3).bold()
                            .foregroundColor(.green)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Longest Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.longestStreak) day\(viewModel.longestStreak == 1 ? "" : "s")")
                            .font(.title3).bold()
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Month label and calendar

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

                // SimpleCalendarView(
                //     daysInMonth: daysInDisplayedMonth,
                //     activeDays: activeDaysInDisplayedMonth,
                //     onDaySelected: { day in
                //         selectedDay = day
                //     }
                // )
                // .padding(.horizontal)

                // Show all sessions for the selected day (future-proof for multiple sessions)
                if let selectedDay = selectedDay {
                    let sessions = viewModel.sessions(for: selectedDay)
                    if !sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Workout Details for \(selectedDay, style: .date)")
                                .font(.headline)
                                .padding(.top)
                            ForEach(sessions, id: \ .id) { session in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Exercises: \(session.exercises.map { $0.name }.joined(separator: ", "))")
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
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            viewModel.refreshProgress()
        }
    }
}