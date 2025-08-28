import SwiftUI

struct TriggerRow: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "bell")
                .foregroundColor(.secondary)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
            Spacer()
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .accessibilityLabel("Delete trigger")
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
