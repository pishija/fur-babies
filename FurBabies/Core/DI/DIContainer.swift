import Foundation

final class DIContainer {
    static let shared = DIContainer()

    let authService: AuthServiceProtocol = FirebaseAuthService()

    lazy var dogRepository: DogProfileRepositoryProtocol = FirebaseDogProfileRepository()
    lazy var createDogUseCase: CreateDogUseCase = CreateDogUseCase(repository: dogRepository)
    lazy var fetchDogsUseCase: FetchDogsUseCase = FetchDogsUseCase(repository: dogRepository)

    private init() {}
}
