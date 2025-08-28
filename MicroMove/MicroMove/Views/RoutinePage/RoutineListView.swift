import SwiftUI

struct RoutineListView: View {
    @ObservedObject var routineViewModel: RoutineViewModel
    @ObservedObject var exercisesViewModel: ExercisesViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel

    @State private var showDeleteAll = false

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            if routineViewModel.routines.isEmpty {
                emptyState
            } else {
                routineList
            }
        }
        .navigationTitle("Routines")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !routineViewModel.routines.isEmpty {
                    Button(role: .destructive) {
                        showDeleteAll = true
                    } label: { Image(systemName: "trash") }
                    .accessibilityLabel("Delete all routines")
                }

                NavigationLink {
                    RoutineWizard(
                        routineViewModel: routineViewModel,
                        exercisesViewModel: exercisesViewModel,
                        userPreferencesViewModel: userPreferencesViewModel
                    )
                } label: { Image(systemName: "plus") }
                .accessibilityLabel("Create routine")
            }
        }
        .confirmationDialog("Delete all routines?",
                            isPresented: $showDeleteAll,
                            titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                routineViewModel.deleteAll()
            }
        }
        .onAppear { routineViewModel.fetchRoutines() }
        .refreshable { routineViewModel.fetchRoutines() }
        // Resolve the destination in one place (lighter than big closures in rows)
        .navigationDestination(for: UUID.self) { rid in
            if let r = routineViewModel.routines.first(where: { $0.id == rid }) {
                RoutineDetailView(routine: r, routineViewModel: routineViewModel, exercisesViewModel: exercisesViewModel, userPreferencesViewModel: userPreferencesViewModel)
            } else {
                Text("Routine not found")
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.secondary)

            Text("No routines yet")
                .font(.title3).bold()

            Text("Create your first routine to get smart reminders and quick access to your favorite exercises.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink {
                RoutineWizard(
                    routineViewModel: routineViewModel,
                    exercisesViewModel: exercisesViewModel,
                    userPreferencesViewModel: userPreferencesViewModel
                )
            } label: {
                Label("Create Routine", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal)
    }

    private var routineList: some View {
        List {
            Section {
                ForEach(routineViewModel.routines, id: \.id) { r in
                    RoutineRowLink(
                        routine: r,
                        onToggle: { routineViewModel.toggleActivateRoutine(r, !r.isActive) },
                        onDelete: { routineViewModel.deleteRoutine(r) },
                        routineViewModel: routineViewModel,
                        exercisesViewModel: exercisesViewModel,
                        userPreferencesViewModel: userPreferencesViewModel
                    )
                }
                .onDelete { idx in
                    let targets = idx.map { routineViewModel.routines[$0] }
                    targets.forEach { routineViewModel.deleteRoutine($0) }
                }
            } header: {
                Text("Your Routines")
                    .font(.subheadline.weight(.semibold))
                    .textCase(nil)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGray6))
    }
}
