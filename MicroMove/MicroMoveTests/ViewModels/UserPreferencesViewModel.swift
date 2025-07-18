import Testing
@testable import MicroMove
import SwiftData
import Foundation

@MainActor
struct UserPreferencesViewModelTests {
    @Test
    func testAddUserPreferencesSetsProperty() async throws {
        let container = try! ModelContainer(
            for: UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await UserPreferencesViewModel(modelContext: modelContext)
        let prefs = UserPreferences(
            reminderInterval: 45,
            reminderTime: Date(timeIntervalSince1970: 1000),
            quietHoursStart: Date(timeIntervalSince1970: 2000),
            quietHoursEnd: Date(timeIntervalSince1970: 3000)
        )
        await viewModel.addUserPreferences(prefs)
        await #expect(viewModel.userPreferences != nil)
        await #expect(viewModel.userPreferences?.reminderInterval == 45)
    }

    @Test
    func testFetchUserPreferencesReturnsCorrectValues() async throws {
        let container = try! ModelContainer(
            for: UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let prefs = UserPreferences(
            reminderInterval: 60,
            reminderTime: Date(timeIntervalSince1970: 1111),
            quietHoursStart: Date(timeIntervalSince1970: 2222),
            quietHoursEnd: Date(timeIntervalSince1970: 3333)
        )
        modelContext.insert(prefs)
        let viewModel = await UserPreferencesViewModel(modelContext: modelContext)
        await viewModel.fetchUserPreferences()
        await #expect(viewModel.userPreferences != nil)
        await #expect(viewModel.reminderInterval == 60)
        await #expect(viewModel.reminderTime == Date(timeIntervalSince1970: 1111))
    }

    @Test
    func testSavePreferencesUpdatesStoredValues() async throws {
        let container = try! ModelContainer(
            for: UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let prefs = UserPreferences(
            reminderInterval: 10,
            reminderTime: Date(timeIntervalSince1970: 100),
            quietHoursStart: Date(timeIntervalSince1970: 200),
            quietHoursEnd: Date(timeIntervalSince1970: 300)
        )
        modelContext.insert(prefs)
        let viewModel = await UserPreferencesViewModel(modelContext: modelContext)
        viewModel.reminderInterval = 99
        viewModel.reminderTime = Date(timeIntervalSince1970: 999)
        viewModel.quietHoursStart = Date(timeIntervalSince1970: 888)
        viewModel.quietHoursEnd = Date(timeIntervalSince1970: 777)
        await viewModel.savePreferences()
        await viewModel.fetchUserPreferences()
        await #expect(viewModel.userPreferences?.reminderInterval == 99)
        await #expect(viewModel.userPreferences?.reminderTime == Date(timeIntervalSince1970: 999))
        await #expect(viewModel.userPreferences?.quietHoursStart == Date(timeIntervalSince1970: 888))
        await #expect(viewModel.userPreferences?.quietHoursEnd == Date(timeIntervalSince1970: 777))
    }

    @Test
    func testDeleteUserPreferencesRemovesProperty() async throws {
        let container = try! ModelContainer(
            for: UserPreferences.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let prefs = UserPreferences(
            reminderInterval: 15,
            reminderTime: Date(),
            quietHoursStart: Date(),
            quietHoursEnd: Date()
        )
        modelContext.insert(prefs)
        let viewModel = await UserPreferencesViewModel(modelContext: modelContext)
        await viewModel.deleteUserPreferences(prefs)
        await #expect(viewModel.userPreferences == nil)
    }
}