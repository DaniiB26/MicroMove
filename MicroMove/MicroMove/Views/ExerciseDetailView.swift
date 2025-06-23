import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise.exerciseDesc)
            Text("Type: \(exercise.type.rawValue)")
            Text("Body Part: \(exercise.bodyPart.rawValue)")
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
