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
        observeSignOut()
    }

    private func resolveInitialState() {
        applicationState = DIContainer.shared.authService.currentUser != nil ? .authenticated : .unauthenticated
    }

    // Watch for token expiry / sign-out triggered outside the app (e.g. account deleted remotely)
    private func observeSignOut() {
        Task { [weak self] in
            for await user in DIContainer.shared.authService.authStateStream {
                guard let self else { return }
                if user == nil {
                    self.applicationState = .unauthenticated
                }
            }
        }
    }

    func markAuthenticated() {
        applicationState = .authenticated
    }

    func markUnauthenticated() {
        applicationState = .unauthenticated
    }
}
