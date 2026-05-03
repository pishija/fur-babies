import Foundation

struct DogProfile: Identifiable, Sendable {
    let id: String
    let userId: String
    var name: String
    var breed: String
    var sex: DogSex
    var birthday: Date
    var weightKg: Double
    var sizeClass: DogSizeClass
    var coatColour: String
    var microchip: String
    var isNeutered: Bool
    var isPublic: Bool
    var temperamentTags: [TemperamentTag]
    var primaryPhotoUrl: String?
    let createdAt: Date
    var updatedAt: Date

    var age: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthday, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        if years >= 1 {
            return "\(years) \(years == 1 ? "year" : "years")"
        }
        return "\(months) \(months == 1 ? "month" : "months")"
    }
}
