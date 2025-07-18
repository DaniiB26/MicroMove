import Testing
@testable import MicroMove
import SwiftData

struct AchievementsViewModelTests {
    @Test
    func testAddAchievementIncreasesCount() async throws {
        let container = try! ModelContainer(
            for: Achievement.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await AchievementsViewModel(modelContext: modelContext)
        let initialCount = await viewModel.achievements.count

        let achievement = Achievement(
            title: "Test",
            achievementDesc: "Test Description",
            type: .streak,
            requirement: 5,
            isUnlocked: false,
            unlockedAt: nil
        )
        await viewModel.addAchievement(achievement)
        await #expect(viewModel.achievements.count == initialCount + 1)
    }

    @Test
    func testDeleteAchievementDecreasesCount() async throws {
        let container = try! ModelContainer(
            for: Achievement.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await AchievementsViewModel(modelContext: modelContext)

        let achievement = Achievement(
            title: "Test",
            achievementDesc: "Test Description",
            type: .streak,
            requirement: 5,
            isUnlocked: false,
            unlockedAt: nil
        )

        await viewModel.addAchievement(achievement)
        let countAfterAdd = await viewModel.achievements.count
        await viewModel.deleteAchievement(achievement)
        await #expect(viewModel.achievements.count == countAfterAdd - 1)
    }

    @Test
    func testFetchExercisesReturnsAll() async throws {
        let container = try! ModelContainer(
            for: Achievement.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await AchievementsViewModel(modelContext: modelContext)

        let achievement1 = Achievement(
            title: "Test1",
            achievementDesc: "Test1 Description",
            type: .streak,
            requirement: 5,
            isUnlocked: false,
            unlockedAt: nil
        )

        let achievement2 = Achievement(
            title: "Test2",
            achievementDesc: "Test2 Description",
            type: .streak,
            requirement: 25,
            isUnlocked: false,
            unlockedAt: nil
        )

        await viewModel.addAchievement(achievement1)
        await viewModel.addAchievement(achievement2)
        await viewModel.fetchAchievements()
        await #expect(viewModel.achievements.count == 2)
    }

    @Test
    func testUpdateAchievementPersistsChange() async throws {
        let container = try! ModelContainer(
            for: Achievement.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await AchievementsViewModel(modelContext: modelContext)

        let achievement = Achievement(
            title: "Test1",
            achievementDesc: "Test1 Description",
            type: .streak,
            requirement: 5,
            isUnlocked: false,
            unlockedAt: nil
        )

        await viewModel.addAchievement(achievement)
        achievement.title = "Achievement"
        await viewModel.updateAchievement(achievement)
        await viewModel.fetchAchievements()
        let updated = await viewModel.achievements.first { $0.id == achievement.id }
        await #expect(updated?.title == "Achievement")
    }
}
