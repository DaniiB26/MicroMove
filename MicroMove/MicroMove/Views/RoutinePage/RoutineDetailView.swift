import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @ObservedObject var routineViewModel: RoutineViewModel

    var body: some View {
        List {
           Section("Exercises") {
               if routine.routineExercise.isEmpty {
                   Text("No exercises yet").foregroundColor(.secondary)
               } else {
                   ForEach(routine.routineExercise, id: \.id) { ex in
                       Text(ex.name) // assuming Exercise has `name`
                   }
               }
           }
           Section("Triggers") {
               if routine.routineTriggers.isEmpty {
                   Text("No triggers").foregroundColor(.secondary)
               } else {
                   ForEach(routine.routineTriggers, id: \.id) { t in
                       Text(t.humanReadable)
                   }
               }
           }
        }
        .navigationTitle(routine.name)
    }
}
