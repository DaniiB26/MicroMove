import SwiftUI

struct ExerciseRowCard: View {
    let exercise: Exercise
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: exercise.type.iconName)
                    .frame(width: 30, height: 30)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(exercise.type.rawValue.capitalized)
                        Text("•")
                        Text(exercise.bodyPart.rawValue.capitalized)
                        Text("•")
                        Text("\(exercise.duration) min")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }

                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .black : .secondary)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}