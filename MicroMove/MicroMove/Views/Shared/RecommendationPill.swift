import SwiftUI

struct RecommendationPill: View {
    let adjustment: Int

    var body: some View {
        let (text, color): (String, Color) = {
            switch adjustment {
            case 1:  return ("Increase intensity", .green)
            case -1: return ("Decrease intensity", .orange)
            default: return ("Keep the same", .secondary)
            }
        }()

        return HStack(spacing: 8) {
            Image(systemName: "sparkles")
            Text(text)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(color.opacity(0.15))
        .foregroundColor(color == .secondary ? .primary : color)
        .clipShape(Capsule())
    }
}

