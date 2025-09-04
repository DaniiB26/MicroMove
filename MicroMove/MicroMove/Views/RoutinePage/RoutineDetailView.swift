import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel

    @State private var showExercisePicker = false
    @State private var triggerExercise: Exercise? = nil
    // Holds both the trigger and its exercise for editing
    @State private var editingContext: EditingTriggerContext? = nil

    // Context for editing sheet to avoid empty sheet on first tap
    struct EditingTriggerContext: Identifiable {
        let id: UUID
        let exercise: Exercise
        let trigger: RoutineTrigger
        init(exercise: Exercise, trigger: RoutineTrigger) {
            self.id = trigger.id
            self.exercise = exercise
            self.trigger = trigger
        }
    }

    private func triggers(for exercise: Exercise) -> [RoutineTrigger] {
        routine.routineTriggers.filter { $0.exercise?.id == exercise.id }
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Card {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(routine.name)
                                    .font(.title3.bold())
                                Text("Routine")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle(isOn: Binding(
                                get: { routine.isActive },
                                set: { routineViewModel.toggleActivateRoutine(routine, $0) }
                            )) {
                                StatusPill(isOn: routine.isActive)
                            }
                            .labelsHidden()
                            .tint(.black)
                        }
                        if let created = routine.createdAt as Date? {
                            Text("Created \(created.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    // Notes card (only if present)
                    if let notes = routine.notes, !notes.isEmpty {
                        Card {
                            SectionHeader(title: "Notes")
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Card {
                        HStack {
                            SectionHeader(title: "Exercises")
                            Spacer()
                            Button {
                                showExercisePicker = true
                            } label: {
                                Label("Add", systemImage: "plus.circle.fill")
                                    .font(.subheadline.bold())
                            }
                        }

                        if routine.routineExercise.isEmpty {
                            EmptyStateView(
                                title: "No exercises yet",
                                subtitle: "Add one to start attaching triggers."
                            )
                            .padding(.top, 8)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(routine.routineExercise, id: \.id) { ex in
                                    ExerciseBlock(
                                        exercise: ex,
                                        triggers: triggers(for: ex),
                                        onRemoveExercise: { routineViewModel.removeExercise(routine, ex) },
                                        onRemoveTrigger: { trig in
                                            routineViewModel.removeTrigger(routine, trig)
                                        },
                                        onAddTrigger: { triggerExercise = ex },
                                        onEditTrigger: { trig in
                                            editingContext = EditingTriggerContext(exercise: ex, trigger: trig)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    Spacer(minLength: 24)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Routine")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExercisePicker) {
            ExerciseSelectionView(routine: routine, routineViewModel: routineViewModel, exercisesViewModel: exercisesViewModel, userPreferencesViewModel: userPreferencesViewModel)
        }
        .sheet(item: $triggerExercise) { ex in
            TriggerEditorView(routine: routine, routineViewModel: routineViewModel, exercise: ex)
        }
        .sheet(item: $editingContext) { ctx in
            TriggerEditorView(routine: routine, routineViewModel: routineViewModel, exercise: ctx.exercise, trigger: ctx.trigger)
        }
    }
}
