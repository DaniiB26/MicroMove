import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            Text(exercise.name)
            Spacer()
            Text(exercise.type.rawValue)
                .foregroundColor(.secondary)
        }
    }
}