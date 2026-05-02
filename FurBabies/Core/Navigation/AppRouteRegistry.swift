import SwiftUI

struct AppRouteRegistry: RouteRegistry {
    private let registries: [any RouteRegistry]

    init(registries: [any RouteRegistry]) {
        self.registries = registries
    }

    func parse(_ url: URL) -> RouteRequest? {
        registries.lazy.compactMap { $0.parse(url) }.first
    }

    func destination(for route: AnyRoute) -> AnyView? {
        registries.lazy.compactMap { $0.destination(for: route) }.first
    }

    func metadata(for route: AnyRoute) -> RouteRequirements? {
        registries.lazy.compactMap { $0.metadata(for: route) }.first
    }
}

final class AppRequirementsEvaluator: RouteRequirementsEvaluator {
    func missingRequirementsFor(_ requirements: RouteRequirements) -> RouteRequirements {
        // Wired to AuthService and ActiveDogStore once auth/onboarding is built
        RouteRequirements()
    }
}
