import Foundation
import os

enum ApplicationState {
    case initializing
    case unauthenticated
    case needsFirstDog(userId: String)
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
        guard let user = DIContainer.shared.authService.currentUser else {
            applicationState = .unauthenticated
            AppLogger.app.info("resolveInitialState — unauthenticated")
            return
        }
        AppLogger.app.info("resolveInitialState — checking dogs for userId=\(user.id)")
        Task {
            await checkDogsAndTransition(userId: user.id)
        }
    }

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
        guard let user = DIContainer.shared.authService.currentUser else {
            applicationState = .unauthenticated
            return
        }
        AppLogger.app.info("markAuthenticated — checking dogs for userId=\(user.id)")
        Task {
            await checkDogsAndTransition(userId: user.id)
        }
    }

    func markUnauthenticated() {
        AppLogger.app.info("markUnauthenticated")
        applicationState = .unauthenticated
    }

    func markDogCreated(dogId: String) {
        AppLogger.app.info("markDogCreated — dogId=\(dogId)")
        ActiveDogStore.shared.setActiveDog(dogId)
        applicationState = .authenticated
    }

    private func checkDogsAndTransition(userId: String) async {
        do {
            let hasDogs = try await DIContainer.shared.fetchDogsUseCase.hasDogs(userId: userId)
            if hasDogs {
                let dogs = try await DIContainer.shared.fetchDogsUseCase.execute(userId: userId)
                if let first = dogs.first {
                    ActiveDogStore.shared.setActiveDog(first.id)
                    AppLogger.app.info("checkDogsAndTransition — activeDog=\(first.id)")
                }
                applicationState = .authenticated
            } else {
                AppLogger.app.info("checkDogsAndTransition — no dogs, needsFirstDog")
                applicationState = .needsFirstDog(userId: userId)
            }
        } catch {
            AppLogger.app.error("checkDogsAndTransition — dogs check failed: \(error). Defaulting to authenticated.")
            applicationState = .authenticated
        }
    }
}
