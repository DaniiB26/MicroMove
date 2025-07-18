import Testing
import Foundation
@testable import MicroMove
import SwiftData

struct ActivityLogViewModelTests {
    @Test
    func testAddActivityLogIncreasesCount() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        let initialCount = await viewModel.activityLogs.count

        let log = ActivityLog(
            timestamp: Date(),
            type: .appOpen,
            activityDesc: "Test Description",
            duration: 1,
            dayContext: .morning
        )
        await viewModel.addActivityLog(log)
        await #expect(viewModel.activityLogs.count == initialCount + 1)
    }

    @Test
    func testFetchActivityLogsReturnsAll() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        let log1 = ActivityLog(
            timestamp: Date(),
            type: .appOpen,
            activityDesc: "Log1",
            duration: 1,
            dayContext: .morning
        )
        let log2 = ActivityLog(
            timestamp: Date(),
            type: .exerciseStart,
            activityDesc: "Log2",
            duration: 2,
            dayContext: .afternoon
        )
        await viewModel.addActivityLog(log1)
        await viewModel.addActivityLog(log2)
        await viewModel.fetchActivityLogs()
        await #expect(viewModel.activityLogs.count == 2)
    }

    @Test
    func testUpdateActivityLogPersistsChange() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        let log = ActivityLog(
            timestamp: Date(),
            type: .appOpen,
            activityDesc: "To Update",
            duration: 1,
            dayContext: .morning
        )
        await viewModel.addActivityLog(log)
        log.activityDesc = "Updated Description"
        await viewModel.updateActivityLog(log)
        await viewModel.fetchActivityLogs()
        let updated = await viewModel.activityLogs.first { $0.id == log.id }
        await #expect(updated?.activityDesc == "Updated Description")
    }

    @Test
    func testDeleteActivityLogDecreasesCount() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        let log = ActivityLog(
            timestamp: Date(),
            type: .appOpen,
            activityDesc: "To Delete",
            duration: 1,
            dayContext: .morning
        )
        await viewModel.addActivityLog(log)
        let countAfterAdd = await viewModel.activityLogs.count
        await viewModel.deleteActivityLog(log)
        await #expect(viewModel.activityLogs.count == countAfterAdd - 1)
    }

    @Test
    func testAddAppOpenCreatesLog() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        await viewModel.addAppOpen()
        await viewModel.fetchActivityLogs()
        let found = await viewModel.activityLogs.contains { $0.type == .appOpen }
        await #expect(found)
    }

    @Test
    func testAddReminderTriggeredCreatesLog() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        await viewModel.addReminderTriggered()
        await viewModel.fetchActivityLogs()
        let found = await viewModel.activityLogs.contains { $0.type == .reminderTriggered }
        await #expect(found)
    }

    @Test
    func testAddReminderRespondedCreatesLog() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        await viewModel.addReminderResponded()
        await viewModel.fetchActivityLogs()
        let found = await viewModel.activityLogs.contains { $0.type == .reminderResponded }
        await #expect(found)
    }

    @Test
    func testAddInactivityDetectedCreatesLog() async throws {
        let container = try! ModelContainer(
            for: ActivityLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ActivityLogViewModel(modelContext: modelContext)
        await viewModel.addInactivityDetected(inactiveTime: 123.0)
        await viewModel.fetchActivityLogs()
        let found = await viewModel.activityLogs.contains { $0.type == .inactivityDetected }
        await #expect(found)
    }
}
