import SwiftUI

struct AchievementListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: AchievementsViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.achievements, id: \.id) { achievement in
                NavigationLink(destination: AchievementDetailView(achievement: achievement)) {
                    AchievementRowView(achievement: achievement)
                }
            }
            .navigationTitle("Achievements")
            // Toolbar for demo achievement button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Demo Achievement") {
                        // Avoid duplicate demo achievements
                        if !viewModel.achievements.contains(where: { $0.title == "First Streak" }) {
                            let demoAchievement = Achievement(
                                title: "First Streak",
                                achievementDesc: "Complete a workout 3 days in a row.",
                                type: .streak,
                                requirement: 3,
                                isUnlocked: false
                            )
                            viewModel.addAchievement(demoAchievement)
                        }
                    }
                }
            }
            // Fetch achievements when view appears
            .onAppear {
                viewModel.fetchAchievements()
            }
        }
    }
}