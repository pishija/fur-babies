import Foundation

final class FetchDogsUseCase {
    private let repository: DogProfileRepositoryProtocol

    init(repository: DogProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String) async throws -> [DogProfile] {
        try await repository.fetchDogs(forUserId: userId)
    }

    func hasDogs(userId: String) async throws -> Bool {
        try await repository.hasDogs(forUserId: userId)
    }
}
