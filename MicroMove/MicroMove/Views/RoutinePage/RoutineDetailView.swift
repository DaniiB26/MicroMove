import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel

    @State private var showExercisePicker = false
    @State private var triggerExercise: Exercise? = nil

    private func triggers(for exercise: Exercise) -> [RoutineTrigger] {
        routine.routineTriggers.filter { $0.exercise?.id == exercise.id }
    }

    var body: some View {
        List {
            Section {
                Toggle("Active", isOn: Binding(
                    get: { routine.isActive },
                    set: { routineViewModel.toggleActivateRoutine(routine, $0) }
                ))
            }

            if let notes = routine.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            ForEach(routine.routineExercise, id: \.id) { ex in
                Section(ex.name) {
                    let tgs = triggers(for: ex)
                    if tgs.isEmpty {
                        Text("No triggers").foregroundColor(.secondary)
                    } else {
                        ForEach(tgs, id: \.id) { trig in
                            Text(trig.humanReadable)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        routineViewModel.removeTrigger(routine, trig)
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                        }
                    }
                    Button("Add Trigger") {
                        triggerExercise = ex
                    }
                    .font(.footnote)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        routineViewModel.removeExercise(routine, ex)
                    } label: { Label("Delete", systemImage: "trash") }
                }
            }

            if routine.routineExercise.isEmpty {
                Section("Exercises") {
                    Text("No exercises yet").foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(routine.name)
        .toolbar {
            Button("Add Exercise") {
                showExercisePicker = true
            }
        }
        .sheet(isPresented: $showExercisePicker) {
            ExerciseSelectionView(routine: routine, routineViewModel: routineViewModel)
        }
        .sheet(item: $triggerExercise) { ex in
            TriggerEditorView(routine: routine, routineViewModel: routineViewModel, exercise: ex)
        }
    }
}