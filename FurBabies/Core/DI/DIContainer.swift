import Foundation

final class DIContainer {
    static let shared = DIContainer()

    let authService: AuthServiceProtocol = FirebaseAuthService()

    private init() {}
}
