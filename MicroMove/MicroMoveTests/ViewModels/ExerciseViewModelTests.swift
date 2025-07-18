import Testing
@testable import MicroMove
import SwiftData

struct ExercisesViewModelTests {
    @Test
    func testAddExerciseIncreasesCount() async throws {
        let container = try! ModelContainer(
            for: Exercise.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ExercisesViewModel(modelContext: modelContext)
        let initialCount = await viewModel.exercises.count

        let exercise = Exercise(
            name: "Test",
            exerciseDesc: "Test Desc",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        await viewModel.addExercise(exercise)
        await #expect(viewModel.exercises.count == initialCount + 1)
    }

    @Test
    func testDeleteExerciseDecreasesCount() async throws {
        let container = try! ModelContainer(
            for: Exercise.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ExercisesViewModel(modelContext: modelContext)
        let exercise = Exercise(
            name: "Test",
            exerciseDesc: "Test Desc",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        await viewModel.addExercise(exercise)
        let countAfterAdd = await viewModel.exercises.count
        await viewModel.deleteExercise(exercise)
        await #expect(viewModel.exercises.count == countAfterAdd - 1)
    }

    @Test
    func testFetchExercisesReturnsAll() async throws {
        let container = try! ModelContainer(
            for: Exercise.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ExercisesViewModel(modelContext: modelContext)
        let exercise1 = Exercise(
            name: "Test1",
            exerciseDesc: "Desc1",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        let exercise2 = Exercise(
            name: "Test2",
            exerciseDesc: "Desc2",
            type: .cardio,
            bodyPart: .legs,
            duration: 10,
            image: "",
            instructions: [],
            visualGuide: []
        )
        await viewModel.addExercise(exercise1)
        await viewModel.addExercise(exercise2)
        await viewModel.fetchExercises()
        await #expect(viewModel.exercises.count == 2)
    }

    @Test
    func testUpdateExerciseChangesPersist() async throws {
        let container = try! ModelContainer(
            for: Exercise.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ExercisesViewModel(modelContext: modelContext)
        let exercise = Exercise(
            name: "Test",
            exerciseDesc: "Test Desc",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        await viewModel.addExercise(exercise)
        exercise.name = "Updated Name"
        await viewModel.updateExercise(exercise)
        await viewModel.fetchExercises()
        let updated = await viewModel.exercises.first { $0.id == exercise.id }
        await #expect(updated?.name == "Updated Name")
    }

    @Test
    func testDeleteAllExercisesRemovesAll() async throws {
        let container = try! ModelContainer(
            for: Exercise.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ExercisesViewModel(modelContext: modelContext)
        let exercise1 = Exercise(
            name: "Test1",
            exerciseDesc: "Desc1",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        let exercise2 = Exercise(
            name: "Test2",
            exerciseDesc: "Desc2",
            type: .cardio,
            bodyPart: .legs,
            duration: 10,
            image: "",
            instructions: [],
            visualGuide: []
        )
        await viewModel.addExercise(exercise1)
        await viewModel.addExercise(exercise2)
        await viewModel.deleteAllExercises(modelContext: modelContext)
        await viewModel.fetchExercises()
        await #expect(viewModel.exercises.isEmpty)
    }

    @Test
    func testMarkExerciseAsDoneSetsCompleted() async throws {
        let container = try! ModelContainer(
            for: Exercise.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = await container.mainContext
        let viewModel = await ExercisesViewModel(modelContext: modelContext)
        let exercise = Exercise(
            name: "Test",
            exerciseDesc: "Test Desc",
            type: .strength,
            bodyPart: .arms,
            duration: 5,
            image: "",
            instructions: [],
            visualGuide: []
        )
        await viewModel.addExercise(exercise)
        await viewModel.markExerciseAsDone(exercise)
        await viewModel.fetchExercises()
        let updated = await viewModel.exercises.first { $0.id == exercise.id }
        await #expect(updated?.isCompleted == true)
    }
}
