import SwiftUI

struct PrimaryFilledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondarySoftButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .background(Color(.systemGray5))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

