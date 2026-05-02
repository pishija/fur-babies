import Foundation

@MainActor
final class ActiveDogStore: ObservableObject {
    static let shared = ActiveDogStore()

    @Published private(set) var activeDogId: String?

    private init() {}

    func setActiveDog(_ dogId: String) {
        activeDogId = dogId
    }

    func clearActiveDog() {
        activeDogId = nil
    }
}
