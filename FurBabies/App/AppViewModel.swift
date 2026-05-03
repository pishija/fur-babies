import Foundation

enum ApplicationState {
    case initializing
    case unauthenticated
    case authenticated
}

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var applicationState: ApplicationState = .initializing

    init() {
        resolveInitialState()
    }

    private func resolveInitialState() {
        // Wired to AuthService.authStateStream once Firebase is configured
        applicationState = .unauthenticated
    }

    func markAuthenticated() {
        applicationState = .authenticated
    }

    func markUnauthenticated() {
        applicationState = .unauthenticated
    }
}
