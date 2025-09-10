import SwiftUI

struct StatusPill: View {
    let isOn: Bool

    var body: some View {
        Text(isOn ? "Active" : "Inactive")
            .font(.caption.weight(.semibold))
            .foregroundColor(isOn ? .white : .black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isOn ? Color.black : Color(.systemGray5))
            .clipShape(Capsule())
    }
}
