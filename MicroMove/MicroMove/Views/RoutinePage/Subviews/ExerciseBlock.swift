import SwiftUI

struct ExerciseBlock: View {
    let exercise: Exercise
    let triggers: [RoutineTrigger]
    let onRemoveExercise: () -> Void
    let onRemoveTrigger: (RoutineTrigger) -> Void
    let onAddTrigger: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header row
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    Image(systemName: exercise.type.iconName)
                        .frame(width: 28, height: 28)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text(exercise.name)
                        .font(.headline)
                        .lineLimit(1)
                }
                Spacer()
                Button(role: .destructive, action: onRemoveExercise) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Remove exercise")
            }

            // Trigger list or empty message
            if triggers.isEmpty {
                Text("No triggers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 2)
            } else {
                VStack(spacing: 8) {
                    ForEach(triggers, id: \.id) { trig in
                        TriggerRow(
                            text: trig.humanReadable,
                            onDelete: { onRemoveTrigger(trig) }
                        )
                    }
                }
            }

            // Add trigger button
            HStack {
                Spacer()
                Button(action: onAddTrigger) {
                    Label {
                        Text("Add Trigger")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 2)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}