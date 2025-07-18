import Testing
@testable import MicroMove
import SwiftData
import Foundation

@MainActor
struct WorkoutSessionViewModelTests {
    @Test
    func testAddWorkoutSessionIncreasesCount() async throws {
        let container = try! ModelContainer(
            for: WorkoutSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await WorkoutSessionViewModel(modelContext: modelContext)
        let initialCount = viewModel.workoutSessions.count
        let session = WorkoutSession(
            date: Date(),
            duration: 30,
            exercises: [],
            startedAt: nil,
            completedAt: nil
        )
        viewModel.addWorkoutSession(session)
        await #expect(viewModel.workoutSessions.count == initialCount + 1)
    }

    @Test
    func testFetchWorkoutSessionsReturnsAll() async throws {
        let container = try! ModelContainer(
            for: WorkoutSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let session1 = WorkoutSession(date: Date(), duration: 10, exercises: [], startedAt: nil, completedAt: nil)
        let session2 = WorkoutSession(date: Date().addingTimeInterval(-86400), duration: 20, exercises: [], startedAt: nil, completedAt: nil)
        modelContext.insert(session1)
        modelContext.insert(session2)
        let viewModel = await WorkoutSessionViewModel(modelContext: modelContext)
        viewModel.fetchWorkoutSessions()
        await #expect(viewModel.workoutSessions.count == 2)
    }

    @Test
    func testUpdateWorkoutSessionPersistsChanges() async throws {
        let container = try! ModelContainer(
            for: WorkoutSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let session = WorkoutSession(date: Date(), duration: 10, exercises: [], startedAt: nil, completedAt: nil)
        modelContext.insert(session)
        let viewModel = await WorkoutSessionViewModel(modelContext: modelContext)
        session.duration = 99
        viewModel.updateWorkoutSession(session)
        viewModel.fetchWorkoutSessions()
        let updated = viewModel.workoutSessions.first { $0.id == session.id }
        await #expect(updated?.duration == 99)
    }

    @Test
    func testDeleteWorkoutSessionRemovesIt() async throws {
        let container = try! ModelContainer(
            for: WorkoutSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let session = WorkoutSession(date: Date(), duration: 10, exercises: [], startedAt: nil, completedAt: nil)
        modelContext.insert(session)
        let viewModel = await WorkoutSessionViewModel(modelContext: modelContext)
        viewModel.deleteWorkoutSession(session)
        await #expect(viewModel.workoutSessions.isEmpty)
    }

    @Test
    func testAddExerciseToSessionCreatesOrUpdatesSession() async throws {
        let container = try! ModelContainer(
            for: WorkoutSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await WorkoutSessionViewModel(modelContext: modelContext)
        let exercise = Exercise(
            name: "Pushup",
            exerciseDesc: "Pushup Desc",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        // No session exists yet, should create one
        viewModel.addExerciseToSession(exercise: exercise)
        await #expect(viewModel.workoutSessions.count == 1)
        await #expect(viewModel.workoutSessions[0].exercises.count == 1)
        await #expect(viewModel.workoutSessions[0].exercises[0].name == "Pushup")
        // Add another exercise, should update today's session
        let exercise2 = Exercise(
            name: "Squat",
            exerciseDesc: "Squat Desc",
            type: .strength,
            bodyPart: .legs,
            duration: 10,
            image: "",
            instructions: [],
            visualGuide: []
        )
        viewModel.addExerciseToSession(exercise: exercise2)
        await #expect(viewModel.workoutSessions.count == 1)
        await #expect(viewModel.workoutSessions[0].exercises.count == 2)
    }
}