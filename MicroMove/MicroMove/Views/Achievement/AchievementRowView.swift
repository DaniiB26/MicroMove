import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement

    var body: some View {
        HStack {
            // Show checkmark if unlocked
            if achievement.isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .accessibilityLabel("Unlocked")
            }
            Text(achievement.title)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title), \(achievement.type.rawValue.capitalized)\(achievement.isUnlocked ? ", unlocked" : ", locked")")
    }
}