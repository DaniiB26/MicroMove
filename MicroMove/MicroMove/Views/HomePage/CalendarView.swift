import SwiftUI

struct CalendarView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var displayedMonth: Date = Date()
    @State private var selectedDay: Date? = nil
    @State private var navigateToHistory = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if let prev = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) {
                        displayedMonth = prev
                        selectedDay = nil
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthLabel(for: displayedMonth))
                    .font(.headline)
                Spacer()
                Button(action: {
                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) {
                        displayedMonth = next
                        selectedDay = nil
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            SimpleCalendarView(
                daysInMonth: daysInDisplayedMonth,
                activeDays: activeDaysInDisplayedMonth,
                onDaySelected: { date in
                    selectedDay = date
                    navigateToHistory = true
                }
            )
            .padding(.horizontal)
            

            // if let selectedDay = selectedDay {
            //     let sessions = progressViewModel.sessions(for: selectedDay)
            //     if !sessions.isEmpty {
            //         VStack(alignment: .leading, spacing: 12) {
            //             Text("Workout Details for \(selectedDay, style: .date)")
            //                 .font(.headline)
            //             ForEach(sessions, id: \.id) { session in
            //                 VStack(alignment: .leading, spacing: 6) {
            //                     Text("Exercises: \(session.exercises.map { $0.name }.joined(separator: ", "))")
            //                     Text("Duration: \(session.duration) min")
            //                     if let started = session.startedAt {
            //                         Text("Started: \(started, style: .time)")
            //                             .font(.caption)
            //                             .foregroundColor(.secondary)
            //                     }
            //                     if let completed = session.completedAt {
            //                         Text("Completed: \(completed, style: .time)")
            //                             .font(.caption)
            //                             .foregroundColor(.secondary)
            //                     }
            //                 }
            //                 .padding()
            //                 .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
            //             }
            //         }
            //         .padding(.horizontal)
            //     } else {
            //         Text("No workout session for this day.")
            //             .italic()
            //             .padding()
            //     }
            // }
        }
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .navigationDestination(isPresented: $navigateToHistory) {
            if let selectedDay {
                WorkoutHistoryView(
                    date: selectedDay,
                    progressViewModel: progressViewModel
                )
            }
        }
    }

    private var daysInDisplayedMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        var days: [Date] = []
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (firstWeekday + 6) % 7

        for _ in 0..<leadingEmptyDays {
            days.append(Date.distantPast)
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    private var activeDaysInDisplayedMonth: Set<Date> {
        let calendar = Calendar.current
        return Set(progressViewModel.workoutSessions
            .filter { calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
            .map { calendar.startOfDay(for: $0.date) })
    }

    private func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
}
