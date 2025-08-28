import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundColor(.secondary)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}