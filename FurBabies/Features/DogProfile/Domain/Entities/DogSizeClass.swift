import Foundation

enum DogSizeClass: String, CaseIterable, Sendable, Codable {
    case toy    = "toy"
    case small  = "small"
    case medium = "medium"
    case large  = "large"
    case giant  = "giant"

    var displayName: String {
        switch self {
        case .toy:    return "Toy"
        case .small:  return "Small"
        case .medium: return "Med"
        case .large:  return "Large"
        case .giant:  return "Giant"
        }
    }

    static func suggested(forWeightKg kg: Double) -> DogSizeClass {
        switch kg {
        case ..<4:    return .toy
        case 4..<10:  return .small
        case 10..<25: return .medium
        case 25..<45: return .large
        default:      return .giant
        }
    }
}
