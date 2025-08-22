import SwiftUI

struct RoutineListView: View {
    @ObservedObject var routineViewModel: RoutineViewModel

    var body: some View {
        VStack {
            List {
                ForEach(routineViewModel.routines, id: \.id) { r in
                    NavigationLink(destination: RoutineDetailView(routine: r, routineViewModel: routineViewModel)) {
                        VStack(alignment: .leading) {
                            Text(r.name)
                                .font(.headline)
                        }
                    }
                }
                .onDelete { idx in
                    let targets = idx.map { routineViewModel.routines[$0] }
                    targets.forEach { routineViewModel.deleteRoutine($0) }
                }
            }

            // Simple red button to delete everything
            Button("Delete All Routines") {
                routineViewModel.deleteAll()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
            .padding()
        }
        .navigationTitle("Routines")
        .toolbar {
            NavigationLink("New") {
                RoutineWizard(routineViewModel: routineViewModel)
            }
        }
        .onAppear { routineViewModel.fetchRoutines() }
    }
}
