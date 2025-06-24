import SwiftUI

struct SimpleCalendarView: View {
    let daysInMonth: [Date]
    let activeDays: Set<Date>

    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
            ForEach(daysInMonth, id: \.self) { day in
                Circle()
                    .fill(activeDays.contains(day) ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(Text("\(Calendar.current.component(.day, from: day))"))
            }
        }
    }
}