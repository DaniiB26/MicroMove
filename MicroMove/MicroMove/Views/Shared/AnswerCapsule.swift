import SwiftUI

struct AnswerCapsule: View {
    let title: String
    var filled: Bool = true

    var body: some View {
        Text(title)
            .font(.body.weight(.semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(filled ? Color.black : Color(.systemGray6))
            .foregroundColor(filled ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.black.opacity(0.08), lineWidth: filled ? 0 : 1)
            )
    }
}

