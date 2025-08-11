import SwiftUI

struct ExerciseCardView: View {
    let exercise: Exercise

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: exercise.type.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.green)
                .padding(.leading, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.black)

                HStack(spacing: 8) {
                    Text("\(exercise.type.rawValue.capitalized) • \(exercise.bodyPart.rawValue.capitalized) • \(exercise.duration) min")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
