import SwiftUI

struct StartWorkoutButton<Destination: View>: View {
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text("Access Routines")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(16)
        }
        .buttonStyle(.plain) // keeps your custom look
    }
}
