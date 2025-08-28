import SwiftUI

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .padding(.bottom, 2)
            .accessibilityAddTraits(.isHeader)
    }
}