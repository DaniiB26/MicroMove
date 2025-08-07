import SwiftUI

struct WorkoutHistoryView: View {
    let date: Date
    @ObservedObject var progressViewModel: ProgressViewModel

    var body: some View {
        let sessions = progressViewModel.sessions(for: date)

        ZStack {
            // Background color
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if sessions.isEmpty {
                        Text("No workout session for this day.")
                            .italic()
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(sessions, id: \.id) { session in
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(session.exercises, id: \.id) { exerciseDTO in
                                    let exercise = exerciseDTO.baseExercise

                                    HStack(alignment: .center, spacing: 12) {
                                        Image(systemName: exercise.type.iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.green)

                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(exercise.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)

                                            HStack(spacing: 24) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Duration")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    Text("\(exercise.duration) min")
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                }

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Started at")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    Text(formatTime(exerciseDTO.startedAt))
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                }

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Finished at")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    Text(formatTime(exerciseDTO.completedAt))
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary)
                                                }
                                            } 
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 1)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6))
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(formatDate(date))
    }

    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date?) -> String {
        guard let date else { return "-" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
