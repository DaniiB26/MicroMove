import SwiftUI

/// Displays detailed information about a single exercise.
struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise.exerciseDesc)
                .font(.body)
            Text("Type: \(exercise.type.rawValue.capitalized)")
            Text("Body Part: \(exercise.bodyPart.rawValue.capitalized)")
            Text("Duration: \(exercise.duration) minutes")
            if !exercise.image.isEmpty {
                Image(exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(exercise.name)
    }
}
