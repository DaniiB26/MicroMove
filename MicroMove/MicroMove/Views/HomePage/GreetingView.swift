import SwiftUI

struct GreetingView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting + Settings
            HStack {
                Text("GOOD \(getDayContext(for: Date()).uppercased()),\n\(userPreferencesViewModel.userName.uppercased())!")
                    .font(.custom("DotGothic16", size: 28))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)

                Spacer()

                NavigationLink(
                    destination: UserPreferencesView(
                        viewModel: userPreferencesViewModel
                    )
                ) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                }

            }

            // Stat Cards
            HStack(spacing: 12) {
                statCard(title: "This Week", value: "\(progressViewModel.weeklyStats().duration) min")
                statCard(title: "This Month", value: "\(progressViewModel.monthlyStats().duration) min")
                statCard(title: "Streak", value: "\(progressViewModel.currentStreak) day\(progressViewModel.currentStreak == 1 ? "" : "s")")
            }
        }
        .padding(.horizontal)
        .onAppear {
            progressViewModel.refreshProgress()
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }

    private func getDayContext(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 6..<12: return "Morning"
        case 12..<18: return "Afternoon"
        case 18..<22: return "Evening"
        default: return "Night"
        }
    }
}
