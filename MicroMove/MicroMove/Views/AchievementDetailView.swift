import SwiftUI

struct AchievementDetailView: View {
    let achievement: Achievement

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(achievement.title)
                    .font(.title)
                    .bold()
                Spacer()

                if achievement.isUnlocked {
                    Label("Unlocked", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                } else {
                    Label("Locked", systemImage: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
            }

            Text(achievement.achievementDesc)
                .font(.body)
                
            HStack {
                Text("Type:")
                    .bold()
                Text(achievement.type.rawValue.capitalized)
                Spacer()
                Text("Requirement:")
                    .bold()
                Text("\(achievement.requirement)")
            }
            .font(.subheadline)

            if let unlockedAt = achievement.unlockedAt, achievement.isUnlocked {
                Text("Unlocked on \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(achievement.title)
    }
}