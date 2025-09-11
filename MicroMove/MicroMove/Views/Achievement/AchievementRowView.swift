import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement
    var currentProgress: Int

    // Clamp progress so we don’t overfill
    private var clamped: Int {
        min(currentProgress, achievement.requirement)
    }
    // Percent removed for simplicity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 52, height: 52)
                Image(systemName: symbol(for: achievement))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)
            }
            .overlay(alignment: .bottomTrailing) {
                if achievement.isUnlocked {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 1.5, x: 0, y: 1)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: 4)
                    .accessibilityHidden(true)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("\(displayTypeName(achievement.type)) • \(requirementText(for: achievement))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Progress bar
                ProgressBar(
                    current: Double(clamped),
                    total: Double(max(1, achievement.requirement)),
                    height: 8,
                    fill: .black
                )

                Text("\(clamped) of \(achievement.requirement) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(displayTypeName(achievement.type)), \(requirementText(for: achievement))")
    }

    // MARK: - Helpers

    private func symbol(for a: Achievement) -> String {
        switch a.type {
        case .streak:         return "flame.fill"
        case .totalMinutes:   return "clock.badge.checkmark"
        case .totalExercises: return "figure.run.circle.fill"
        }
    }

    private func requirementText(for a: Achievement) -> String {
        switch a.type {
        case .streak:         return "\(a.requirement) day\(a.requirement == 1 ? "" : "s")"
        case .totalMinutes:   return "\(a.requirement) min"
        case .totalExercises: return "\(a.requirement) exercises"
        }
    }

    private func displayTypeName(_ type: Achievement.AchievementType) -> String {
        switch type {
        case .streak:         return "Streak"
        case .totalMinutes:   return "Total Minutes"
        case .totalExercises: return "Total Exercises"
        }
    }

}