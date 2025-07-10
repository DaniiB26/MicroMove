import SwiftUI

struct AchievementListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: AchievementsViewModel

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
            let sortedAchievements = viewModel.achievements.sorted {
                if $0.type == $1.type {
                    return $0.requirement < $1.requirement
                } else {
                    return $0.type.rawValue < $1.type.rawValue
                }
            }
            let grouped = Dictionary(grouping: sortedAchievements, by: { $0.type })
            let orderedTypes: [Achievement.AchievementType] = [.streak, .totalMinutes, .totalExercises]

            List {
                ForEach(orderedTypes, id: \.self) { type in
                    if let achievementsForType = grouped[type] {
                        Section(header: Text(type.rawValue.capitalized)) {
                            ForEach(achievementsForType, id: \.id) { achievement in
                                NavigationLink(destination: AchievementDetailView(achievement: achievement)) {
                                    AchievementRowView(achievement: achievement)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Achievements")
            // Toolbar for demo achievement button
            // .toolbar {
            //     ToolbarItem(placement: .navigationBarTrailing) {
            //         HStack {
            //             Button("Add Demo Achievements") {
            //                 addDemoAchievements()
            //             }
            //             Button("Delete All") {
            //                 deleteAllAchievements()
            //             }
            //         }
            //     }
            // }
            // Fetch achievements when view appears
            .onAppear {
                viewModel.fetchAchievements()
            }
        }
    }
}