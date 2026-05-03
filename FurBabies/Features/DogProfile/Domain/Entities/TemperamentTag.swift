import Foundation

enum TemperamentTag: String, CaseIterable, Sendable, Codable {
    case friendly     = "Friendly"
    case playful      = "Playful"
    case calm         = "Calm"
    case protective   = "Protective"
    case trained      = "Trained"
    case anxious      = "Anxious"
    case goodWithKids = "Good with kids"
    case goodWithDogs = "Good with dogs"

    var displayName: String { rawValue }
}
