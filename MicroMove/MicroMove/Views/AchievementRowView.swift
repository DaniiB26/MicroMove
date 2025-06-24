import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement

    var body: some View {
        HStack {
            Text(achievement.title)
            Spacer()
            Text(achievement.type.rawValue.capitalized)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title), \(achievement.type.rawValue.capitalized)")
    }
}