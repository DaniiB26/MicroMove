import SwiftUI

struct AchievementListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: AchievementsViewModel
    @ObservedObject var progressViewModel: ProgressViewModel

    func addDemoAchievements() {
        let streaks = [3, 7, 14, 30, 100]
        let minutes = [10, 30, 60, 120, 300]
        let exercises = [5, 10, 25, 50, 100]
        let allAchievements: [Achievement] =
            streaks.map { Achievement(title: "Streak: \($0) days", achievementDesc: "Complete a workout \($0) days in a row.", type: .streak, requirement: $0) } +
            minutes.map { Achievement(title: "Minutes: \($0)", achievementDesc: "Accumulate \($0) total minutes of exercise.", type: .totalMinutes, requirement: $0) } +
            exercises.map { Achievement(title: "Exercises: \($0)", achievementDesc: "Complete \($0) exercises.", type: .totalExercises, requirement: $0) }
        for achievement in allAchievements {
            if !viewModel.achievements.contains(where: { $0.title == achievement.title && $0.type == achievement.type }) {
                viewModel.addAchievement(achievement)
            }
        }
    }

    func deleteAllAchievements() {
        for achievement in viewModel.achievements {
            viewModel.deleteAchievement(achievement)
        }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                let sorted = viewModel.achievements.sorted {
                    if $0.type == $1.type { return $0.requirement < $1.requirement }
                    return $0.type.rawValue < $1.type.rawValue
                }
                let grouped = Dictionary(grouping: sorted, by: { $0.type })
                let ordered: [Achievement.AchievementType] = [.streak, .totalMinutes, .totalExercises]

                List {
                    ForEach(ordered, id: \.self) { type in
                        if let group = grouped[type] {
                            Section(header: Text(type.rawValue.capitalized)) {
                                ForEach(group, id: \.id) { achievement in
                                    let progress = progressViewModel.progressValue(for: achievement)
                                    NavigationLink {
                                        AchievementDetailView(achievement: achievement, currentProgress: progress)
                                    } label: {
                                        AchievementRowView(achievement: achievement, currentProgress: progress)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Achievements")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Demo Achievements", action: addDemoAchievements)
                        Button("Delete All", role: .destructive, action: deleteAllAchievements)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                viewModel.fetchAchievements()
                progressViewModel.refreshProgress()
            }
        }
    }
}