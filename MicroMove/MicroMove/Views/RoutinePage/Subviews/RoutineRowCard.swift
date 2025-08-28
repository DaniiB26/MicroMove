import SwiftUI

struct RoutineRowCard: View {
    let routine: Routine
    let onToggleActive: () -> Void

    private var exerciseCount: Int { routine.routineExercise.count }
    private var triggerCount: Int  { routine.routineTriggers.count }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Leading icon
            Image(systemName: routine.isActive ? "bolt.fill" : "bolt.slash")
                .foregroundColor(routine.isActive ? .green : .secondary)
                .frame(width: 30, height: 30)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Title + subtitle
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(routine.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    StatusPill(isOn: routine.isActive)
                        .onTapGesture { onToggleActive() }
                }
                Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s") • \(triggerCount) trigger\(triggerCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
