import SwiftUI

struct ProgressBar: View {
    var current: Double
    var total: Double
    var height: Double = 8
    var fill: Color = .black
    var background: Color = Color(.systemGray5)

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return max(0, min(1, current / total))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(background)
            SwiftUI.ProgressView(value: fraction)
                .progressViewStyle(.linear)
                .tint(fill)
        }
        .frame(height: CGFloat(height))
        .clipShape(Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(fraction * 100)) percent")
    }
}
