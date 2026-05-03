import Foundation

@MainActor
final class DogProfileViewModel: ObservableObject {
    @Published private(set) var dog: DogProfile?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let fetchDogsUseCase: FetchDogsUseCase

    init(fetchDogsUseCase: FetchDogsUseCase? = nil) {
        self.fetchDogsUseCase = fetchDogsUseCase ?? DIContainer.shared.fetchDogsUseCase
    }

    func load(dogId: String, userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let dogs = try await fetchDogsUseCase.execute(userId: userId)
            dog = dogs.first { $0.id == dogId }
            if dog == nil {
                AppLogger.dog.warning("load — dog not found id=\(dogId)")
            }
        } catch {
            AppLogger.dog.error("load — failed: \(error)")
            errorMessage = "Couldn't load your dog's profile."
        }
    }
}
