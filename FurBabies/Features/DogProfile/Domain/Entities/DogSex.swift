import Foundation

enum DogSex: String, CaseIterable, Sendable, Codable {
    case male = "male"
    case female = "female"

    var displayName: String {
        switch self {
        case .male:   return "Male"
        case .female: return "Female"
        }
    }

    var neuteredLabel: String {
        switch self {
        case .male:   return "Neutered"
        case .female: return "Spayed"
        }
    }
}
