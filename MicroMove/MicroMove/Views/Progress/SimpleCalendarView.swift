import SwiftUI

struct SimpleCalendarView: View {
    let daysInMonth: [Date]
    let activeDays: Set<Date>
    let onDaySelected: (Date) -> Void

    @State private var selectedDate: Date? = nil

    var body: some View {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols

        VStack(spacing: 12) {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                    if day == Date.distantPast {
                        Color.clear.frame(height: 32)
                    } else {
                        let isActive = activeDays.contains(calendar.startOfDay(for: day))
                        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: day) } ?? false
                        let dayNumber = calendar.component(.day, from: day)

                        ZStack {
                            if isActive {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 34, height: 34)
                            } else if isSelected {
                                Circle()
                                    .stroke(Color.pink, lineWidth: 2)
                                    .frame(width: 34, height: 34)
                            }

                            Text("\(dayNumber)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(isActive ? .white : .primary)
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            selectedDate = day
                            onDaySelected(day)
                        }
                    }
                }
            }
        }
    }
}
