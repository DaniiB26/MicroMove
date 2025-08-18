import Foundation

enum FitnessLevel: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
    var id: String { rawValue.capitalized }
    var display: String { rawValue.capitalized }
}

enum FitnessGoal: String, Codable, CaseIterable {
    case strength, cardio, mobility, endurance, weightLoss
    var id: String { rawValue }
    var display: String { rawValue.capitalized }
}
