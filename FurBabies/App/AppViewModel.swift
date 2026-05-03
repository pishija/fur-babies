import Foundation
import os

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
        let hasSession = DIContainer.shared.authService.currentUser != nil
        applicationState = hasSession ? .authenticated : .unauthenticated
        AppLogger.app.info("resolveInitialState — \(hasSession ? "authenticated" : "unauthenticated")")
    }

    // Watch for token expiry / sign-out triggered outside the app (e.g. account deleted remotely)
    private func observeSignOut() {
        Task { [weak self] in
            for await user in DIContainer.shared.authService.authStateStream {
                guard let self else { return }
                if user == nil {
                    AppLogger.app.info("observeSignOut — auth stream emitted nil, moving to unauthenticated")
                    self.applicationState = .unauthenticated
                }
            }
        }
    }

    func markAuthenticated() {
        AppLogger.app.info("markAuthenticated")
        applicationState = .authenticated
    }

    func markUnauthenticated() {
        AppLogger.app.info("markUnauthenticated")
        applicationState = .unauthenticated
    }
}
