import SwiftUI

struct RoundIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

