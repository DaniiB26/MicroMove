import Foundation

/// Represents the type of exercise in the app
enum ExerciseType: String, Codable, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case stretch = "Stretch"
}

/// Represents the target body part of an exercise
enum BodyPart: String, Codable, CaseIterable {
    case core = "Core"
    case arms = "Arms"
    case legs = "Legs"
    case back = "Back"
    case chest = "Chest"
    case abs = "Abs"
    case shoulders = "Shoulders"
    case fullBody = "Full Body"
}