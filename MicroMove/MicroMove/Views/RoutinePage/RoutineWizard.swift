import SwiftUI

struct RoutineWizard: View {
    @ObservedObject var routineViewModel: RoutineViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("New Routine")
                .font(.title)

            TextField("Routine name", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Save Routine") {
                let routine = Routine(name: name)
                routineViewModel.addRoutine(routine)
                dismiss()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}
