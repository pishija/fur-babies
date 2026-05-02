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
        // Wired to AuthService once auth feature is built
        applicationState = .unauthenticated
    }
}
