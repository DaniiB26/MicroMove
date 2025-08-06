import SwiftUI

struct StartWorkoutButton: View {
    var body: some View {
        Button(action: {
            print("Start new workout tapped")
        }) {
            Text("Start a new workout")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(16)
        }
    }
}