import SwiftUI

struct StepDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
            Spacer()
        }
    }
}

