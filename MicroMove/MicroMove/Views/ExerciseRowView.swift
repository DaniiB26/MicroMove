import SwiftUI

/// A single row representing an exercise in the list.
struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            Text(exercise.name)
            Spacer()
            Text(exercise.type.rawValue.capitalized)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(exercise.name), type: \(exercise.type.rawValue.capitalized)")
    }
}