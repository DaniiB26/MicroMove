import SwiftUI

struct Chip: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

