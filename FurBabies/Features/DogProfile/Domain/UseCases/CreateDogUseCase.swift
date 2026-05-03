import Foundation

final class CreateDogUseCase {
    private let repository: DogProfileRepositoryProtocol

    init(repository: DogProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ dog: DogProfile) async throws -> String {
        try await repository.createDog(dog)
    }
}
