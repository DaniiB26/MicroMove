import SwiftUI

struct WeeklyCheckInPrompt: View {
    @ObservedObject var userPreferencesViewModel: UserPreferencesViewModel
    var onDone: (() -> Void)?
 
    @Environment(\.dismiss) private var dismiss

    // Flow state
    enum Step { case intro, node(String), summary }
    @State private var step: Step = .intro
    @State private var answers: [String: Bool] = [:]

    // Ordered node ids (for progress indicator)
    private let flowOrder = ["easy", "hard", "frequency", "pain", "recovery"]

    // Node model
    struct QuestionNode {
        let id: String
        let prompt: String
        let next: (Bool, inout [String: Bool]) -> Step
    }

    private var nodes: [String: QuestionNode] {
        [
            "easy": QuestionNode(id: "easy", prompt: "Was the week too easy?") { answer, answers in
                answers["easy"] = answer
                return answer ? .summary : .node("hard")
            },

            "hard": QuestionNode(id: "hard", prompt: "Was the week too hard?") { answer, answers in
                answers["hard"] = answer
                return answer ? .summary : .node("frequency")
            },

            "frequency": QuestionNode(id: "frequency", prompt: "Did you hit your target frequency?") { answer, answers in
                answers["frequency"] = answer
                return .node("pain")
            },

            "pain": QuestionNode(id: "pain", prompt: "Did you feel unusual pain or excessive fatigue?") { answer, answers in
                answers["pain"] = answer
                return .node("recovery")
            },

            "recovery": QuestionNode(id: "recovery", prompt: "Did you recover well between workouts?") { answer, answers in
                answers["recovery"] = answer
                return .summary
            }
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        header

                        switch step {
                        case .intro:
                            Card { introView }
                        case .node(let id):
                            if let index = flowOrder.firstIndex(of: id) {
                                StepDots(current: index, total: flowOrder.count)
                                    .padding(.horizontal, 16)
                            }
                            Card { nodeView(id) }
                        case .summary:
                            Card { summaryView }
                        }

                        Spacer(minLength: 8)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Weekly Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { onDone?(); dismiss() }
                }
            }
        }
        .tint(.black)
    }

    // Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Weekly Check-In")
                    .font(.title.bold())
                Text("A quick pulse check to tune your plan.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.title2)
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }

    // Sections

    private var introView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did your training go last week?")
                .font(.headline)
            Text("Answer a few quick questions to tune intensity.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Answer") { step = .node("easy") }
                    .buttonStyle(.borderedProminent)

                Button("Skip this week") {
                    onDone?()
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 2)
        }
    }

    @ViewBuilder
    private func nodeView(_ id: String) -> some View {
        if let node = nodes[id] {
            VStack(alignment: .leading, spacing: 16) {
                Text(node.prompt)
                    .font(.headline)

                HStack(spacing: 12) {
                    Button {
                        var local = answers
                        step = node.next(true, &local)
                        answers = local
                    } label: { AnswerCapsule(title: "Yes") }
                    .buttonStyle(.plain)

                    Button {
                        var local = answers
                        step = node.next(false, &local)
                        answers = local
                    } label: { AnswerCapsule(title: "No", filled: false) }
                    .buttonStyle(.plain)
                }

                Divider().padding(.vertical, 4)

                HStack {
                    Button("Back") { step = previousStep(for: id) }
                        .buttonStyle(.bordered)
                    Spacer()
                }
            }
        } else {
            Text("Missing node: \(id)")
                .foregroundColor(.secondary)
        }
    }

    private var summaryView: some View {
        let adj = adjustment()
        let current = userPreferencesViewModel.fitnessLevel
        let next = adjustedLevel(from: current, by: adj)

        return VStack(alignment: .leading, spacing: 14) {
            Text("Summary")
                .font(.headline)

            RecommendationPill(adjustment: adj)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Current", systemImage: "figure.walk")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(current.display)
                        .font(.subheadline.bold())
                }
                HStack {
                    Label("Next", systemImage: "arrow.forward.circle")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(next.display)
                        .font(.subheadline.bold())
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                Button("Back") { step = summaryBackStep() }
                    .buttonStyle(.bordered)

                Spacer()

                Button("Apply and Finish") {
                    userPreferencesViewModel.fitnessLevel = next
                    userPreferencesViewModel.savePreferences()
                    onDone?()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 6)
        }
    }

    // Logic

    private func adjustment() -> Int {
        var score = 0
        if answers["easy"] == true { score += 2 }
        if answers["hard"] == true { score -= 2 }
        if let hitFreq = answers["frequency"] { score += hitFreq ? 1 : -1 }
        if let pain = answers["pain"], pain == true { score -= 2 }
        if let recovered = answers["recovery"] { score += recovered ? 1 : -1 }

        if score >= 2 { return 1 }   // increase
        if score <= -2 { return -1 } // decrease
        return 0                     // keep
    }

    private func adjustedLevel(from current: FitnessLevel, by delta: Int) -> FitnessLevel {
        switch (current, delta) {
        case (.beginner, 1): return .intermediate
        case (.intermediate, 1): return .advanced
        case (.advanced, 1): return .advanced
        case (.advanced, -1): return .intermediate
        case (.intermediate, -1): return .beginner
        case (.beginner, -1): return .beginner
        default: return current
        }
    }

    private func previousStep(for id: String) -> Step {
        switch id {
        case "easy": return .intro
        case "hard": return .node("easy")
        case "frequency": return .node("hard")
        case "pain": return .node("frequency")
        case "recovery": return .node("pain")
        default: return .intro
        }
    }

    private func summaryBackStep() -> Step {
        if answers["recovery"] != nil { return .node("recovery") }
        if answers["hard"] != nil { return .node("hard") }
        return .node("easy")
    }
}