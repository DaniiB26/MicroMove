import SwiftUI

struct AchievementDetailView: View {
    let achievement: Achievement
    var currentProgress: Int = 0

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                    // Badge + status
                    VStack(spacing: 8) {
                        Image(systemName: heroSymbol(for: achievement.type))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(achievement.isUnlocked ? .green : .secondary)

                        Text(achievement.isUnlocked ? "Unlocked" : "Locked")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(achievement.isUnlocked ? .green : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                    // Title
                    Text(achievement.title)
                        .font(.title.bold())
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Description
                    Card {
                        Text(achievement.achievementDesc)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Details
                    Card {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Details")
                                .font(.headline)

                            HStack {
                                Label(achievement.type.rawValue.capitalized, systemImage: "tag")
                                Spacer()
                                Label(requirementText(for: achievement), systemImage: "target")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }

                    // Progress (only if still locked)
                    if !achievement.isUnlocked {
                        Card {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Progress")
                                    .font(.headline)

                                ProgressBar(
                                    current: Double(currentProgress),
                                    total: Double(max(1, achievement.requirement))
                                )

                                HStack {
                                    Text("\(currentProgress) / \(achievement.requirement)")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(progressHint(current: currentProgress, total: achievement.requirement))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Unlocked date (if any)
                    if achievement.isUnlocked, let date = achievement.unlockedAt {
                        Card {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Unlocked on \(date.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.footnote)
                                Spacer()
                            }
                            .foregroundColor(.secondary)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(achievement.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func requirementText(for a: Achievement) -> String {
        switch a.type {
        case .streak:
            return "\(a.requirement) day\(a.requirement == 1 ? "" : "s")"
        case .totalMinutes:
            return "\(a.requirement) min"
        case .totalExercises:
            return "\(a.requirement) exercises"
        }
    }

    private func progressHint(current: Int, total: Int) -> String {
        let remaining = max(0, total - current)
        if remaining == 0 { return "Complete!" }
        if remaining == 1 { return "1 to go" }
        return "\(remaining) to go"
    }

    private func heroSymbol(for type: Achievement.AchievementType) -> String {
        switch type {
        case .streak:         return "flame.fill"
        case .totalMinutes:   return "clock.badge.checkmark"
        case .totalExercises: return "figure.run.circle.fill"
        }
    }
}