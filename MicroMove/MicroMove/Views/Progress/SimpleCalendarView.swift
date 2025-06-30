import SwiftUI

struct SimpleCalendarView: View {
    let daysInMonth: [Date]
    let activeDays: Set<Date>
    let onDaySelected: (Date) -> Void

    var body: some View {
        // Weekday headers
        let weekdaySymbols = Calendar.current.shortWeekdaySymbols
        VStack(spacing: 4) {
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(symbol)
                }
            }
            // Calendar grid
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                ForEach(daysInMonth, id: \.self) { day in
                    Circle()
                        .fill(activeDays.contains(day) ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(Text("\(Calendar.current.component(.day, from: day))")
                            .font(.caption)
                            .foregroundColor(.primary))
                        .onTapGesture {
                            onDaySelected(day)
                        }
                        .accessibilityLabel("Day \(Calendar.current.component(.day, from: day)) \(activeDays.contains(day) ? ", active" : ", inactive")")
                }
            }
        }
    }
}