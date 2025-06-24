import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement

    var body: some View {
        HStack {
            Text(achievement.title)
            Spacer()
            Text(achievement.type.rawValue.capitalized)
                .foregroundColor(.secondary)
            // Show checkmark if unlocked
            if achievement.isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .accessibilityLabel("Unlocked")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title), \(achievement.type.rawValue.capitalized)\(achievement.isUnlocked ? ", unlocked" : ", locked")")
    }
}